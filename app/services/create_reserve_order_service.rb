class CreateReserveOrderService

  def initialize(cart, reserve_times)
    @cart = cart
    @reserve_times = reserve_times
  end

  def excute
    ActiveRecord::Base.transaction do
      @cart.lock!
      # 連打対策 cartのトランザクション中はロックする
      order = Order.create_order(@cart, Order::RESERVE)
      OrderProduct.create_order_product(order, @cart)
      Product.decrement_inventory(@cart)
      #代引きの時もline_pay支払いの時と住所の設定方法は同じ
      order.set_address_with_line_pay
      order.update!(verified: true)

      ReserveDetail.upsert(@cart, order, @reserve_times)

      @cart.destroy!
    end
  end

  private

  attr_accessor :cart
end
