module Payments::CommonHelper
  def quantity_with_size(cart_product)
    SizeProduct.releated_size(
      cart_product.product, cart_product.size
    ).quantity
  end
end
