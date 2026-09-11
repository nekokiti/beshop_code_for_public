require 'rails_helper'

RSpec.describe Payments::PaypayController, type: :request do
  create_sample_order
  let!(:pay_pay_info) { create(:pay_pay_info, company: company) }

  # Tag doesn't have show page
  # describe "GET #show" do
  # end

  describe "from reserve to confirm of pay pay" do

  # it "can accept transaction_id from pay pay" do
  #   get payments_paypay_reserve_url cart.cart_hash
  #   json = JSON.parse(response.body)
  #   expect(json['body']['resultInfo']['code']).to eq "SUCCESS"
  #   expect(json['body']['resultInfo']['message']).to eq "Success"
  #   expect(response.status).to eq 200
  # end
  #
  # it "recieves code SUCCESS on confirm" do
  #   get payments_paypay_reserve_url cart.cart_hash
  #   json_payment = JSON.parse(response.body)
  #   get json_payment['body']['data']['redirectUrl']
  #   json_confirm = JSON.parse(response.body)
  #   expect(json_confirm['body']['code']).to eq "SUCCESS"
  #   #支払いが完了する前はcreatedになる。testはここまで↓
  #   expect(json_confirm['body']['status']).to eq "CREATED"
  #   expect(response.status).to eq 200
  # end

  # it "recieves code REQUEST_ACCEPTED on confirm as cancel" do

  # cancelは実際に支払いを行わないとstatusが更新されないのでテスト出来ない
  # 支払い前にcancel a payment してもGetCodePaymentDetailsは
  # {"code":"SUCCESS","status":"CREATED","message":"Success"} を返す
  # この後で支払いを行うと(言わばcancelが予約状態なので)支払いが失敗して GetCodePaymentDetailsは
  # {"code":"SUCCESS","status":"FAILED","merchantPaymentId":"merchant20201023f","message":"Success"} を返す
  # つまり先にcancelを送っても実際の支払いが無い場合はstatusはcreatedになる。

  # end

  end
end
