require 'rails_helper'

RSpec.describe OrdersController, type: :request do
  login_company
  create_sample_order
  describe "GET #index" do
    before do
      order.verify(Faker::Lorem.characters(20))
    end
    it "returns a success response" do
      get orders_url
      expect(response).to be_success
    end
    context "no condition" do
      it "returns a login_company's order" do
        get orders_url
        expect(response.body).to include Order.my_orders(company).first.txn_id
      end
    end
    context "search with time" do
      let(:old_days) do
        {
          'created_at_from(1i)' => '2018',
          'created_at_from(2i)' => '1',
          'created_at_from(3i)' => '1',
          'created_at_to(1i)' => '2018',
          'created_at_to(2i)' => '1',
          'created_at_to(3i)' => '31'
        }
      end
      it "can't hit any order" do
        get orders_url, params: { form_order_find_form: old_days }
        expect(response.body).not_to include Order.my_orders(company).first.txn_id
      end
    end
    context "search with time" do
      let(:now_days) do
        {
          'created_at_from(1i)' => Time.zone.now.year,
          'created_at_from(2i)' => Time.zone.now.month,
          'created_at_from(3i)' => Time.zone.now.day,
          'created_at_to(1i)' => Time.zone.now.year,
          'created_at_to(2i)' => Time.zone.now.month,
          'created_at_to(3i)' => Time.zone.now.day
        }
      end
      it "download_csv" do
        get orders_url, params: { form_order_find_form: now_days, csv: '' }
        expect(response).to be_success
      end
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get order_url order.to_param
      expect(response).to be_success
    end
    context "not with cash_on_delivery" do
      it "returns a right information related by order" do
        order.set_address_with_line_pay
        get order_url order.to_param
        expect(response.body).to include order.first_name
        expect(response.body).to include order.address_city
        expect(response.body).to include order.line_user.email
        expect(response.body).to include order.zip
        expect(response.body).to include order.tax.to_s
        expect(response.body).not_to include "代引き手数料"
        expect(response.body).to include order.mc_handling.to_s
        expect(response.body).to include order.mc_shipping.to_s
      end
    end
    context "with cash_on_delivery" do
      it "has cash_on_delivery price" do
        order.set_address_with_line_pay
        order.update!(payment_method: Order::CASH_ON_DELIVERY, cash_on_delivery_price: 500)
        get order_url order.to_param
        expect(response.body).to include "代引き手数料"
        expect(response.body).to include order.cash_on_delivery_price.to_s
      end
    end
  end

  describe "GET #new" do
    before do
      get new_order_url, params: {}
    end
    it "returns a success response" do
      expect(response).to be_success
    end
  end

=begin
orderをコントローラー側でcreateする事は無い
  describe "POST #create" do
    context "with valid params" do
      it "creates a new Order" do
        expect {
          post :create, params: {order: valid_attributes}, session: valid_session
        }.to change(Order, :count).by(1)
      end

      it "redirects to the created order" do
        post :create, params: {order: valid_attributes}, session: valid_session
        expect(response).to redirect_to(Order.last)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: {order: invalid_attributes}, session: valid_session
        expect(response).to be_success
      end
    end
  end
=end

=begin
orderの管理画面からの削除については検討中
  describe "DELETE #destroy" do
    it "destroys the requested order" do
      order = Order.create! valid_attributes
      expect {
        delete :destroy, params: {id: order.to_param}, session: valid_session
      }.to change(Order, :count).by(-1)
    end

    it "redirects to the orders list" do
      order = Order.create! valid_attributes
      delete :destroy, params: {id: order.to_param}, session: valid_session
      expect(response).to redirect_to(orders_url)
    end
  end
=end

end
