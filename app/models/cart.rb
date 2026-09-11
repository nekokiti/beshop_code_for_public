class Cart < ApplicationRecord
  require 'securerandom'

  belongs_to :line_user
  belongs_to :company
  has_one :order
  has_one :take_over_time
  has_many :cart_products, dependent: :destroy
  has_many :products, through: :cart_products
  acts_as_paranoid

  MAX_ITEMS = 10

  def self.out_of_inventory(cart)
    out_of_inventory = []
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

      unless cart_product.size.nil?
        cart_product.product.size_name = cart_product.size.name
        if SizeProduct.releated_size(
          cart_product.product, cart_product.size
        ).quantity <= 0
          CartProduct.del_cart_products(cart_product.id)
        end
      else
        if cart_product.product.quantity <= 0
          CartProduct.del_cart_products(cart_product.id)
        end
      end
      out_of_inventory.push(cart_product)
    end
    return out_of_inventory
  end

  def self.create_cart(user, company, chat_mode: false)
    Cart.find_or_create_by!(
      line_user: user, company: company, chat_mode_flg: chat_mode
    ) do |cart|
      cart.cart_hash = SecureRandom.uuid
      cart.company = company
    end
  end

  def self.get_my_cart(user, target_company, chat_mode_flg = false)
    Cart.find_by(line_user: user, company: target_company, chat_mode_flg: chat_mode_flg)
  end

  def self.get_cart_by_hash(hash)
    Cart.find_by(cart_hash: hash)
  end

  def self.get_cart_by_hash_with_deleted(hash)
    Cart.with_deleted.find_by(cart_hash: hash)
  end

  def self.get_cart_by_id_with_deleted(id)
    Cart.with_deleted.find(id)
  end

  def need_extra_fee?
    products.exists?(no_extra_fee: false)
  end

  def calc_total_products_price_in_cart_with_tax
    price = 0
    coupon = 0
    cart_products.each do |cart_product|
      next coupon += cart_product.product.price if cart_product.product.coupon_flg
      price += cart_product.product.calc_price_with_tax * cart_product.quantity
    end
    price - coupon > 0 ? price - coupon : 0
  end

  def calc_total_products_price_in_cart_without_tax
    price = 0
    coupon = 0
    cart_products.each do |cart_product|
      next coupon += cart_product.product.price if cart_product.product.coupon_flg

      price += cart_product.product.price * cart_product.quantity
    end
    price - coupon > 0 ? price - coupon : 0
  end

  def calc_coupon_price_in_cart
    price = 0
    cart_products.each do |cart_product|
      price += cart_product.product.price if cart_product.product.coupon_flg
    end
    price
  end

  def calc_tax
    calc_total_products_price_in_cart_with_tax -
      calc_total_products_price_in_cart_without_tax
  end

  def calc_total_price_in_cart
    calc_total_products_price_in_cart_with_tax +
      company.shipping.shipping_fee.to_i +
      company.shipping.extra_fee.to_i
  end

  def add_cart(product_id, quantity, size_id = nil)
    # 最大10アイテムまで
    if products.count >= MAX_ITEMS
      'カートには最大' + MAX_ITEMS.to_s + '個の商品しか入りません'
    elsif (products.where(otorioki_flg: true).exists? && !Product.find(product_id).otorioki_flg) ||
          (products.where(otorioki_flg: false).exists? && Product.find(product_id).otorioki_flg) 
        I18n.t('activerecord.models.cart.mix_in_error_with_take_over')
    else
      quantity = quantity.to_i unless quantity.is_a?(Integer)
      new_record = CartProduct.update_cart_product(self, product_id, quantity, size_id)
      if new_record
        I18n.t('activerecord.models.cart.add_cart')
      else
        I18n.t('activerecord.models.cart.change_quantity')
      end
    end
  end
end
