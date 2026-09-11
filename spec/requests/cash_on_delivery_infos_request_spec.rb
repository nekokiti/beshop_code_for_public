require 'rails_helper'

RSpec.describe CashOnDeliveryInfosController, type: :request do
  login_company
  let(:cash_on_delivery_info) { create(:cash_on_delivery_info, company: company, price: 500) }

  describe 'GET #new' do
    before do
      get new_cash_on_delivery_info_url, params: {}
    end
    it 'returns a success response' do
      expect(response).to be_success
    end
    it 'assigns a cash_on_delivery_info instance' do
      expect(response.body).to include '代引き支払情報設定'
    end
  end

  describe 'GET #edit' do
    before do
      get edit_cash_on_delivery_info_url cash_on_delivery_info.to_param
    end
    it 'returns a success response' do
      expect(response).to be_success
    end
    it 'assigns a edit_cash_on_delivery_info' do
      expect(response.body).to include cash_on_delivery_info.price.to_s
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        company: company,
        price: 500,
        enable_flg: true
      }
    end
    it 'creates a new CashOnDeliveryInfo' do
      expect {
        post cash_on_delivery_info_url, params: { cash_on_delivery_info: valid_attributes }
      }.to change(CashOnDeliveryInfo, :count).by(1)
    end

    it 'redirects to the created cash_on_delivery_info' do
      post cash_on_delivery_info_url, params: { cash_on_delivery_info: valid_attributes }
      expect(response).to \
        redirect_to(edit_cash_on_delivery_info_url CashOnDeliveryInfo.last)
    end
  end

  describe 'PUT #update' do
    let(:new_attributes) do
      {
        id: cash_on_delivery_info.id,
        price: 800,
        enable_flg: true
      }
    end
    it 'is success to request' do
      put cash_on_delivery_info_url, params: { cash_on_delivery_info: new_attributes }
      expect(response.status).to eq 302
      expect(response).to \
        redirect_to(edit_cash_on_delivery_info_url cash_on_delivery_info)
    end
    it 'updates the requested cash_on_delivery_info' do
      put cash_on_delivery_info_url, params: { cash_on_delivery_info: new_attributes }
      expect(cash_on_delivery_info.reload.price).to eq(800)
    end
  end
end
