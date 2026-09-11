module OrdersHelper
  def full_name(order)
    "#{order.last_name} #{order.first_name}様"
  end

  def address(order)
    "#{order.zip} #{order.address_state} #{order.address_city} #{order.address_street}"
  end

  def sub_total(order)
    total = 0
    order.order_products.each do |op|
      next if op.coupon_flg

      total += op.product_price * op.quantity
    end
    total
  end
end
