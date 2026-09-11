require 'rails_helper'

RSpec.describe PayPayInfosController, type: :request do
  login_company
  let(:pay_pay_info) { create(:pay_pay_info, company: company) }

  describe 'GET #new' do
    before do
      get new_pay_pay_info_url, params: {}
    end
    it 'returns a success response' do
      expect(response).to be_success
    end
    it 'assigns a line_pay_info instance' do
      expect(response.body).to include 'PayPay支払い情報設定'
    end
  end

  describe 'GET #edit' do
    before do
      get edit_pay_pay_info_url pay_pay_info.to_param
    end
    it 'returns a success response' do
      expect(response).to be_success
    end
    it 'assigns a pay_pay_info' do
      expect(response.body).to include pay_pay_info.client_id
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        company: company,
        client_id: Faker::Lorem.characters(20),
        client_secret: Faker::Lorem.characters(20),
        merchant_id: Faker::Lorem.characters(20),
        enable_flg: true
      }
    end
    it 'creates a new PayPayInfo' do
      expect {
        post pay_pay_info_url, params: { pay_pay_info: valid_attributes }
      }.to change(PayPayInfo, :count).by(1)
    end

    it 'redirects to the created pay_pay_info' do
      post pay_pay_info_url, params: { pay_pay_info: valid_attributes }
      expect(response).to \
        redirect_to(edit_pay_pay_info_url PayPayInfo.last)
    end
  end

  describe 'PUT #update' do
    before do
      @encryptor = Encrypt.new
    end
    let(:plane_secret) do
      Faker::Lorem.characters(20)
    end
    let(:encrypted_secret) do
      @encryptor.encrypt(plane_secret)
    end
    let(:new_attributes) do
      {
        id: pay_pay_info.id,
        client_id: Faker::Lorem.characters(20),
        client_secret: plane_secret,
        merchant_id: Faker::Lorem.characters(20),
        enable_flg: true
      }
    end

    it 'is success to request' do
      put pay_pay_info_url, params: { pay_pay_info: new_attributes }
      expect(response.status).to eq 302
      expect(response).to \
        redirect_to(edit_pay_pay_info_url pay_pay_info)
    end

    it 'updates the requested pay_pay_info' do
      put pay_pay_info_url, params: {pay_pay_info: new_attributes }
      expect(pay_pay_info.reload.client_id).to \
        eq(new_attributes[:client_id])
      expect(@encryptor.decrypt(pay_pay_info.client_secret)).to \
        eq(@encryptor.decrypt(encrypted_secret))
    end
  end
end
