class CreateCashOnDeliveryOrderService

  def initialize(cart)
    @cart = cart
  end

  def excute
    ActiveRecord::Base.transaction do
      @cart.lock!
      # 連打対策 cartのトランザクション中はロックする
      order = Order.create_order(@cart, Order::CASH_ON_DELIVERY)
      OrderProduct.create_order_product(order, @cart)
      Product.decrement_inventory(@cart)
      #代引きの時もline_pay支払いの時と住所の設定方法は同じ
      order.set_address_with_line_pay
      order.update!(cash_on_delivery_price: @cart.company.cash_on_delivery_info.price, verified: true)
      @cart.destroy!
    end
  end

  private

  attr_accessor :cart
end
