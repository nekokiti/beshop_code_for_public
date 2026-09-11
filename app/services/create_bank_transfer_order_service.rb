class CreateBankTransferOrderService

  def initialize(cart)
    @cart = cart
  end

  def excute
    ActiveRecord::Base.transaction do
      @cart.lock!
      # 連打対策 cartのトランザクション中はロックする
      order = Order.create_order(@cart, Order::BANK_TRANSFER)
      OrderProduct.create_order_product(order, @cart)
      Product.decrement_inventory(@cart)
      #銀行振り込み(簡易)の時もline_pay支払いの時と住所の設定方法は同じ
      order.set_address_with_line_pay
      order.update!(verified: true)
      @cart.destroy!
    end
  end

  private

  attr_accessor :cart
end
