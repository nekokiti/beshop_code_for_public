class CreateTakeoutOrderService

  def initialize(cart)
    @cart = cart
  end

  def create
    ActiveRecord::Base.transaction do
      order = Order.create_order(@cart, Order::TAKEOUT)
      @cart.take_over_time.update!(order: order)
      OrderProduct.create_order_product(order, order.cart)
      order.update!(verified: true)
      @cart.destroy!
      order
    end
  end

  private

  attr_accessor :cart
end
