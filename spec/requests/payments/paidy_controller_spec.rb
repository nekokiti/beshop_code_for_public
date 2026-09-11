require 'rails_helper'

RSpec.describe Payments::PaidyController, type: :request do
  create_sample_order
  let!(:paidy_info) { create(:paidy_info, company: company) }
  describe "checkout" do
    subject { get payments_paidy_checkout_url cart.cart_hash; response }
    it { is_expected.to have_http_status(:success) }
  end
  describe "webhook" do
    it "returns 200 and create order and paidy_capture_ with order" do
      post payments_paidy_webhook_url, params: paidy_webhook_api_data(cart)
      expect(response.status).to eq 200
      expect(PaidyCapture.find_by(order_id: cart.order.id).capture_id).to eq 'cap_test'
    end
  end
  describe "callback_api" do
    it "returns 200 and create order and paidy_capture_ with order" do
      post payments_paidy_callback_api_url, params: paidy_callback_api_data(cart)
      json = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(json["status"]).to eq "SUCCESS"
      expect(PaidyCapture.find_by(order_id: cart.order.id).capture_id).to eq 'cap_test'
    end
  end
  describe "order_info" do
    it "returns hash for pay_load" do
      post payments_paidy_order_info_url, params: { cart_hash: cart.cart_hash }
      json = JSON.parse(response.body)
      expect(response.status).to eq 200
      expect(json["order_info"]["amount"]).to eq cart.calc_total_price_in_cart
    end
  end
end
