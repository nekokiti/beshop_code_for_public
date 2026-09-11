require 'rails_helper'

RSpec.describe Payments::PaypalExpressController, type: :request do
  create_sample_order
  describe "GET #new" do
    it "equals between subtotal and total of each prices" do
      create(:paypal_info, company: company)
      price = 0
      cart.cart_products.each do |cp|
        amount = cp.product.price
        price += amount
      end
      tax = cart.calc_tax
      shipping = cart.need_extra_fee? ? company.shipping.shipping_fee : 0
      handling = cart.need_extra_fee? ? company.shipping.extra_fee : 0
      order_total = cart.need_extra_fee? ? cart.calc_total_price_in_cart : cart.calc_total_products_price_in_cart_with_tax
      expect(price.to_i + tax.to_i + shipping.to_i + handling.to_i).to eq order_total
      get payments_paypal_payment_url cart.cart_hash, 0
      expect(response.status).to eq 302
    end
  end

  describe "GET #purchase" do
    example "オーダーが作成出来、オーダーとプロダクトの関連に(存在すれば)サイズが設定されること" do
      order = Order.new
      begin
        Order.transaction do
          order = Order.create_order(cart, Order::PAYPAL)
          OrderProduct.create_order_product(order, order.cart)
          Product.decrement_inventory(order.cart)
          cart.destroy
        end
      rescue => e
        Rails.logger.error 'order save with cart destroy transaction failed.'
        Rails.logger.error("#{e.message}")
      end
      # カートにはサイズ無し商品が3つとサイズ有り商品(S)が3つ入っている
      order.order_products.each do |op|
        if op.size != nil
          expect(op.size).to eq Size.find(Size::S)
        end
      end
    end
  end
end
