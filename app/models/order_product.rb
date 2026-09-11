class OrderProduct < ApplicationRecord
  belongs_to :order
  belongs_to :size

  def self.create_order_product(order, cart)
    cart.cart_products.each do |cart_product|
      op = OrderProduct.new
      op.attributes = {
        order: order,
        quantity: cart_product.quantity,
        product_name: cart_product.product.name,
        product_price: cart_product.product.calc_price_with_tax
      }
      op.jancode = cart_product.product.try(:jancode)
      op.coupon_flg = cart_product.product.coupon_flg
      if cart_product.product.has_size
        op.attributes = {
          size: cart_product.size,
          size_name: cart_product.size.name
        }
      end
      op.save!
    end
  end
end
