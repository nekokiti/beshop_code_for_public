class CartProduct < ApplicationRecord
  belongs_to :cart
  belongs_to :product
  belongs_to :size

  DESTROY_CART_PRODUCT_MSG = '商品を削除しました'
  DONT_EXISTS_CART_PRODUCT_MSG = '商品がありません'

  def self.update_cart_product(cart, product_id, quantity, size_id = nil)
    if size_id.nil?
      cart_product = find_or_create_by(cart_id: cart.id,
                                       product_id: product_id)
    else
      cart_product = find_or_create_by(cart_id: cart.id,
                                       product_id: product_id,
                                       size: Size.find(size_id))
    end
    new_record = cart_product.created_at == cart_product.updated_at
    cart_product.update!(quantity: quantity)
    new_record
  end

  def self.del_cart_products(cart_products_id)
    #not found の時findだとエラーになるが、find_byだとnilを返す
    cart_product = self.find_by(id: cart_products_id)
    unless cart_product.nil?
      cart_product.destroy
      DESTROY_CART_PRODUCT_MSG
    else
      DONT_EXISTS_CART_PRODUCT_MSG
    end
  end

  def self.product_quantity(cart, product, size = nil)
    my_cart_product(cart, product, size).quantity
  end

  def self.check_already_had?(cart, product, size = nil)
    my_cart_product(cart, product, size).present?
  end

  def self.my_cart_product(cart, product, size = nil)
    find_by(cart: cart, product: product, size: size)
  end

end
