require 'rails_helper'

RSpec.describe Payments::LineController, type: :request do
  create_sample_order
  let(:line_pay_info) { create(:line_pay_info, company: company) }
  let(:proxy) { ENV['FIXIE_URL'] }
  let!(:x_line_channel_id){
    line_pay_info.channel_id
  }
  let!(:x_line_channe_secret){
    line_pay_info.decrypt_keys
  }

  # Tag doesn't have show page
  # describe "GET #show" do
  # end

  describe "from reserve to confirm of line pay" do

    transaction_id = ""

    context "chat mode" do
      context "with no size" do
        it "can redirect to line reserve url" do
          res = get payments_reserve_by_one_to_one_url(
            product_id: products.first.id,
            line_id: line_user.line_id,
            size_id: Size::NO_SIZE
          )
          expect(res).to eq 302
        end
      end
      context "with size" do
        it "can redirect to line reserve url" do
          res = get payments_reserve_by_one_to_one_url(
            product_id: products.first.id,
            line_id: line_user.line_id,
            size_id: Size::M
          )
          expect(res).to eq 302
        end
      end
    end

=begin linepay apiへのリクエストはflexiを消費してしまうため
    context "with bot mode" do
      it "can accept transaction_id from line pay" do
        get payments_line_reserve_url cart.cart_hash
        json = JSON.parse(response.body)
        transaction_id = json['transaction_id']
        expect(json['transaction_id']).not_to be_nil
        expect(json['return_message']).to eq "Success."
        expect(response.status).to eq 200
      end
    end
=end

    it "recieves transaction_id at confirm" do
      order = Order.create_order(cart, Order::LINE_PAY)
      transaction_id ="test_txn_id"
      order.update!(txn_id: transaction_id)
      get payments_line_confirm_url, params: { transactionId: transaction_id }
      expect(controller.params[:transactionId]).to eq transaction_id
      expect(order.reload.verified).to be_truthy
      expect(order.reload.discount).to eq 100
    end

  end
end
