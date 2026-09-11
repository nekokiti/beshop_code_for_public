require 'rails_helper'

RSpec.describe MinimumPricesController, type: :request do
  login_company
  let(:minimum_price) { create(:minimum_price, company: company) }

  describe 'GET #new' do
    before do
      get new_minimum_price_url, params: {}
    end
    it 'returns a success response' do
      expect(response).to be_success
    end
    it 'assigns a minimum_price instance' do
      expect(response.body).to include '最低購入金額設定'
    end
  end

  describe 'GET #edit' do
    before do
      get edit_minimum_price_url minimum_price.to_param
    end
    it 'returns a success response' do
      expect(response).to be_success
    end
    it 'assigns a minimum_price' do
      expect(response.body).to include minimum_price.price.to_s
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        price: 500
      }
    end
    it 'creates a new minimum_price' do
      expect do
        post minimum_price_url, params: { minimum_price: valid_attributes }
      end.to change(MinimumPrice, :count).by(1)
    end

    it 'redirects to the created minimum_price' do
      post minimum_price_url, params: { minimum_price: valid_attributes }
      expect(response).to \
        redirect_to(edit_minimum_price_url MinimumPrice.last)
    end
  end

  describe 'PUT #update' do
    let(:new_attributes) do
      {
        id: minimum_price.id,
        price: 1000
      }
    end
    it 'is success to request' do
      put minimum_price_url, params: { minimum_price: new_attributes }
      expect(response.status).to eq 302
      expect(response).to \
        redirect_to(edit_minimum_price_url minimum_price)
    end
    it 'updates the requested minimum_price' do
      put minimum_price_url, params: { minimum_price: new_attributes }
      expect(minimum_price.reload.price).to \
        eq(new_attributes[:price])
    end
  end
end
