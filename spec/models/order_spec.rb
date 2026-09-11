require 'rails_helper'

RSpec.configure do |config|
  # (snip)
  #config.use_transactional_fixtures = false
  # (snip)
end

RSpec.describe Order, type: :model do
  create_coupon
  create_sample_order
  let(:verified_order) do
    # orderはcartと紐づいているのでcartを消さない限り
    # let(:verified_order)したら
    # orderは常にこのオブジェクトを返すので注意
    res = create(:order,
      line_user: cart.line_user,
      cart: cart,
      txn_id: Faker::Lorem.characters(20),
      total_price: Faker::Commerce.price,
      company: cart.company,
      verified: true)
  end
  let(:params) { create_ipn(cart) }

  describe "create_order" do
    context "no coupon is included" do
      it "creates order" do
        order = Order.create_order(cart, Order::LINE_PAY)
        expect(order.cart.products).to eq cart.products
      end
    end
    context "coupon is included" do
      it "creates order" do
        cart.add_cart(coupon.id, 1)
        order = Order.create_order(cart, Order::LINE_PAY)
        expect(order.discount).to eq coupon.price
      end
    end
    context "only no extrafee products" do
      let(:products_has_no_extra_fee) do
        create(:product, company: company, no_extra_fee: true)
      end
      it "creates order" do
          cart.cart_products.each do |cp|
            CartProduct.del_cart_products(cp.id)
          end
        cart.add_cart(products_has_no_extra_fee.id, 1)
        order = Order.create_order(cart.reload, Order::LINE_PAY)
        expect(order.cart.products).to eq cart.products
        expect(order.total_price.to_i).to eq cart.calc_total_products_price_in_cart_with_tax
        expect(order.mc_shipping.to_i).to eq 0
        expect(order.mc_handling.to_i).to eq 0
      end
    end
  end
  describe "my_orders" do
    before do
      @sign_in_company = verified_order.company
      @another_company = create(:company)
    end
    context "the company has orders" do
      it "gets related order of sign_in_compnay" do
        gotten_order = Order.my_orders(@sign_in_company)
        expect(gotten_order.first).to eq verified_order
      end
    end
    context "the company doesn't have orders" do
      it "dosen't get related order of another_company" do
        gotten_order = Order.my_orders(@another_company)
        expect(gotten_order.first).not_to eq verified_order
      end
    end
    context "the order isn't verified" do
      it "dosen't include non verified order of sign_in_compnay" do
        non_verified_order = verified_order
        non_verified_order.update!(verified: false)
        expect(Order.my_orders(order.company)).not_to include non_verified_order
      end
    end
  end
  describe "order_histories" do
      context "all of the orders are verified" do
        it "gets all of order_histories" do
          verified_order
          expect(Order.order_histories(line_user, company, 5).first).to eq verified_order
        end
      end
      context "there is a non verified order in orders" do
        it "dosen't include non verified order in order_histories" do
          non_verified_order = order
          verified_order
          expect(Order.order_histories(line_user, company, 5)).not_to include non_verified_order
        end
      end
  end
  describe "order_validation" do
    context "no coupon included" do
      it "veridates order" do
        CartProduct.update_cart_product(cart, products_has_size.first.id, 3, Size::M)
        expect(order.order_validation(ipn_params:params, order:order)).to be_truthy
      end
    end
    context "coupon included" do
      it "veridates order" do
        cart.add_cart(coupon.id, 1)
        expect(order.order_validation(ipn_params:params, order:order)).to be_truthy
      end
    end
  end
  describe "verify" do
    it "verifies order" do
      expect(order.verify(params['txn_id'])).to be_truthy
    end
  end
  describe "with_in_one_month" do
    it "gets only within one month order" do
      company.update!(occupation_mst_id: OccupationMst::RESERVE)

      two_month_ago = [Time.current.ago(2.month).strftime("%Y-%m-%d"), '09:00', '21:00']
      CreateReserveOrderService.new(cart, two_month_ago).excute

      cart = Cart.create_cart(line_user, company)
      CartProduct.update_cart_product(cart, products.first.id, 1)
      one_month_ago = [Time.current.ago(1.month).strftime("%Y-%m-%d"), '09:00', '21:00']
      CreateReserveOrderService.new(cart, one_month_ago).excute

      cart = Cart.create_cart(line_user, company)
      CartProduct.update_cart_product(cart, products.first.id, 1)
      twenty_ninth_days_ago = [Time.current.ago(1.month).tomorrow.strftime("%Y-%m-%d"), '09:00', '21:00']
      CreateReserveOrderService.new(cart, twenty_ninth_days_ago).excute

      cart = Cart.create_cart(line_user, company)
      CartProduct.update_cart_product(cart, products.first.id, 1)
      yesterday = [Time.current.yesterday.strftime("%Y-%m-%d"), '09:00', '21:00']
      CreateReserveOrderService.new(cart, yesterday).excute

      cart = Cart.create_cart(line_user, company)
      CartProduct.update_cart_product(cart, products.first.id, 1)
      current = [Time.current.strftime("%Y-%m-%d"), '09:00', '21:00']
      CreateReserveOrderService.new(cart, current).excute

      reserve_order_histories = Order.order_histories(line_user, company, 5)
      res = Order.with_in_one_month(reserve_order_histories)
      expect(res).not_to include reserve_order_histories.last
      expect(res).not_to include reserve_order_histories.fourth
      expect(res).to include reserve_order_histories.third
      expect(res).to include reserve_order_histories.second
      expect(res).to include reserve_order_histories.first
    end
  end
  describe "display_name" do
    context "with CASH_ON_DELIVERY" do
      it "returns 代引き" do
        create(:cash_on_delivery_info, company: company, price:500)
        order = Order.create_order(cart, Order::CASH_ON_DELIVERY)
        expect(order.display_name).to eq '代引き'
      end
    end
    context "with BANK_TRANSFER" do
      it "returns 銀行振込" do
        order = Order.create_order(cart, Order::BANK_TRANSFER)
        expect(order.display_name).to eq '銀行振込'
      end
    end
  end
  describe "set address for order" do
    context "with_line pay" do
      it "sets payer" do
        res = order.set_address_with_line_pay
        expect(res).to be_truthy
        expect(order.address_state).to eq order.line_user.address_state
        expect(order.address_city).to eq order.line_user.address_city
        expect(order.address_street).to eq order.line_user.address_street
        expect(order.first_name).to eq order.line_user.first_name
        expect(order.last_name).to eq order.line_user.last_name
        expect(order.zip).to eq order.line_user.zip
      end
    end
    context "with_line pay and occupation is hotel" do
      it "sets payer" do
        company.update!(occupation_mst_id: OccupationMst::HOTEL)
        line_user.update!(room_number: '305')
        res = order.set_address_with_line_pay
        expect(res).to be_truthy
        expect(order.room_number).to eq order.line_user.room_number
      end
    end
    context "with_paypal" do
      it "sets payer" do
        res = order.set_address_with_paypal(params)
        expect(res).to be_truthy
        expect(order.address_city).to eq params[:address_city]
        expect(order.mc_shipping).to eq params[:mc_shipping]
        expect(order.mc_handling).to eq params[:mc_handling]
        expect(order.tax).to eq params[:tax]
        expect(order.tel).to eq line_user.tel
      end
    end
    context "with_paypal and occupation is hotel" do
      it "sets payer" do
        company.update!(occupation_mst_id: OccupationMst::HOTEL)
        line_user.update!(room_number: '305')
        res = order.set_address_with_line_pay
        expect(res).to be_truthy
        expect(order.room_number).to eq order.line_user.room_number
      end
    end
  end
end
