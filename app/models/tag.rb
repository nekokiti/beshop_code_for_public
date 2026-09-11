class Tag < ApplicationRecord
  has_many :taggings, dependent: :delete_all
  has_many :products, through: :taggings
  belongs_to :company
  validates_uniqueness_of :tag_name, :scope => :company_id
  validates :tag_name, presence: true
  acts_as_paranoid
  mount_uploader :image_path, ImageUploader

  MAX_ITEM_NUM = 50;

  scope :my_tags, ->(current_company) { where(company: current_company).order(:id) }

  #def self.getTags(wakati)
  #  self.where("tag_name LIKE '%#{wakati}%'")
  #end

  # 商品を持つタグとurlのみを持つタグをドッキング
  def mix_tag_with_product_and_tag_has_url(company, index)
    tags_with_p = Tag.my_tags(company).distinct.joins(:products).where(["tags.id > ?", index]).limit(MAX_ITEM_NUM)
    tags_have_u = Tag.my_tags(company).distinct.where.not(url: [nil, ""]).where(["tags.id > ?", index]).limit(MAX_ITEM_NUM)
    # 商品を持つタグがurlを持っている場合も有る(重複の可能性も有る)のでuniq!する
    tags_array = tags_with_p.all.ids.concat(tags_have_u.all.ids).uniq
    Tag.where(id: tags_array).order(:id).limit(MAX_ITEM_NUM)
  end

  def self.getMyTags(company, index)
    tags = new.mix_tag_with_product_and_tag_has_url(company, index)
    if tags.empty?
      false
      # new.mix_tag_with_product_and_tag_has_url(company, 0)
    else
      tags
    end
  end

end
