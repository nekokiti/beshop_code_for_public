class Product < ApplicationRecord
  require 'nkf'
  require 'bigdecimal'
  belongs_to :company
  has_many :taggings, dependent: :delete_all
  has_many :tags, through: :taggings
  has_many :cart_products, dependent: :destroy
  has_many :carts, through: :cart_products
  has_many :sticon_products
  has_many :sticons, through: :sticon_products, dependent: :delete_all
  has_many :size_products, dependent: :delete_all
  has_many :sizes, through: :size_products
  has_one :otorioki_time, dependent: :destroy
  accepts_nested_attributes_for :tags
  accepts_nested_attributes_for :otorioki_time
  accepts_nested_attributes_for :size_products, reject_if: :reject_size
  mount_uploader :image_path, ImageUploader
  mount_uploader :movie_path, MovieUploader

  validates :name, presence: true
  validates :price, presence: true
  validates :description, presence: true, length: { maximum: 60 }
  validates :image_path, presence: true

  scope :my_products, ->(current_company) { where(company_id: current_company).order(:id) }
  scope :has_inventory, ->() { where("products.quantity > 0") }

  attr_accessor :size_name

  MAX_ITEMS = 10
  BATCH_SIZE = 30 # (条件付きでも)指定されたIDより多い商品を全部取得するのは無駄なので、30ずつoffsetで回す
  TAX_RATE = 0.1
  REDUCTION_TAX_RATE = 0.08
  TAX_FREE_RATE = 0

  def self.include_otorioki_flg?(products)
    products.each do |p|
      return true if p.otorioki_flg
    end
    false
  end

  def calc_price_with_tax
    tax_rate = TAX_RATE
    if tax_free_flg
      tax_rate = TAX_FREE_RATE
    elsif reduction_tax
      tax_rate = REDUCTION_TAX_RATE
    end
    (BigDecimal(price.to_s) * BigDecimal((1 + tax_rate).to_s)).floor
  end

  def self.get_recommend_products(product_id, current_company)
    products = new.get_products_by_recommend_with_positive_inventory_and_size(
      product_id,
      current_company
    )

    return false if products.empty?

    products
  end

  def self.get_products_by_tag(tag_id, product_id, current_company)
    tag = Tag.find_by(id: tag_id)
    products = new.get_products_by_tag_with_positive_inventory_and_size(
      tag,
      product_id,
      current_company
    )

    return false if products.empty?

    products
  end

  def self.check_inventory(cart)
    cart.cart_products.each do |cart_product|
      # サイズ無しの場合在庫は商品テーブルが持つ
      next if
        cart_product.size.nil? && \
        (cart_product.product.quantity - cart_product.quantity) >= 0

      # サイズ有りの場合在庫はサイズ_商品テーブルが持つ
      next if !cart_product.size.nil? && \
              (SizeProduct.releated_size(
                cart_product.product, cart_product.size
              ).quantity - cart_product.quantity) >= 0

      return false
    end
    true
  end

  def self.decrement_inventory(cart)
    cart.cart_products.each do |cart_product|
      num = cart_product.quantity
      if cart_product.size.nil?
        cart_product.product.decrement!(:quantity, num)
      else
        SizeProduct.releated_size(
          cart_product.product,
          cart_product.size
        ).decrement!(:quantity, num)
      end
    end
  end

  def calc_price(item_ids)
    total = 0
    item_ids.each do |id|
      p = Product.find(id)
      total += p.calc_price_with_tax
    end
    total
  end

  def reject_size(attributes)
    !has_size
  end

  def get_products_by_recommend_with_positive_inventory_and_size(product_id, current_company)
    products = []
    Product.my_products(current_company)
           .where(recommend_flg: true)
           .where("products.id > ?", product_id)
           .find_each(batch_size: BATCH_SIZE) do |p|
              if p.has_size
                products << p unless SizeProduct.check_quantity(p).blank?
              elsif p.quantity.positive?
                products << p
              end
              break if products.size >= MAX_ITEMS
           end
    products
  end

  def get_products_by_tag_with_positive_inventory_and_size(tag, product_id, current_company)
    products = []
    tag.products
       .my_products(current_company)
       .where("products.id > ?", product_id)
       .find_each(batch_size: BATCH_SIZE) do |p|
          if p.has_size
            products << p unless SizeProduct.check_quantity(p).blank?
          elsif p.quantity.positive?
            products << p
          end
          break if products.size >= MAX_ITEMS
       end
    products
  end

=begin #{{{
  after_initialize do
    self.products = []
    self.keywords = []
  end
=end

=begin
  def set_products_by_sticons(sticon, current_company)
    sticon.products.my_products(current_company).each do |p|
      @products.push(p)
    end
  end
=end

=begin
  def set_products_by_keywords(msg, current_company)
    tags = []
    natto = Natto::MeCab.new
    natto.parse(msg) do |n|
      strAry = n.feature.split(",")
      #Rails.logger.debug("#{print(strAry)}")
      if strAry[0] != "助詞" && strAry[0] != "BOS/EOS"
        tag = ""
        res = n.surface
        if strAry[0] == "形容詞" || strAry[0] == "連体詞"
          tag = Tag.getTags(res.chop)
        else
          tag = Tag.getTags(res)
        end
        hiragana = ""
        if tag.blank?
           if res.match(/\p{Katakana}/) #カタカナの場合、平仮名に直し、再チェック
            hiragana = NKF.nkf("--hiragana -w", res)
            if strAry[0] == "形容詞" || strAry[0] == "連体詞"
              tag = Tag.getTags(hiragana.chop)
            else
              tag = Tag.getTags(hiragana)
            end
          else #ひらがなもしくは漢字の場合、読みからカタカナを取得し、再チェック
            hiragana = res
            katakana = strAry[7]
            if strAry[0] == "形容詞" || strAry[0] == "連体詞"
              tag = Tag.getTags(katakana.chop)
            else
              tag = Tag.getTags(katakana)
            end
            if tag.blank? && res.match(/[一-龠々]/)#漢字の場合、カタカナを平仮名に直しし、再チェック
                hiragana = NKF.nkf("--hiragana -w", katakana)
                if strAry[0] == "形容詞" || strAry[0] == "連体詞"
                  tag = Tag.getTags(hiragana.chop)
                else
                  tag = Tag.getTags(hiragana)
                end
            end
          end
          #テキストが平仮名かカタカナでタグが漢字の可能性がある場合はAPI経由で変換する
          if tag.blank? && !res.match(/[一-龠々]/)
            #Rails.logger.debug("#{print(res)}")
            res = getKanji(hiragana)
            res.each do |kanji|
              tag = Tag.getTags(kanji)
              unless tag.blank?
                break
              end
            end
          end
        end
        unless tag.blank?
          tags.push(tag)
        else
          logger.debug("no tag was hitted")
        end

        @keywords.push(n.surface)
      end
    end
    unless tags.empty?
      tags.flatten!.each do |t|
        t.products.my_products(current_company).each do |p|
          @products.push(p)
        end
      end
    end
    #UserKeyword.setkeywords(keywords)
    #@products.uniq!
    #return @products
    return nil
  end
=end

=begin
  def get_products_order_by_priority
    return @products.group_by{|e| e}.sort_by{|k,v|-v.size}.map(&:first)
  end
=end

=begin
  def get_products
    return @products
  end
=end

=begin
  def get_keywords
    #set_products_by_keywords をすると、@keywrodsに使ったkeywordが保存されている
    return @keywords
  end
=end

=begin
  def get_kanji(sentence)
    getKanji(sentence)
  end
=end 
#}}}

end
