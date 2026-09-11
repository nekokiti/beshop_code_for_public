require 'rails_helper'

RSpec.describe LinePayInfosController, type: :request do
  login_company
  let(:line_pay_info) { create(:line_pay_info, company: company) }

  describe 'GET #new' do
    before do
      get new_line_pay_info_url, params: {}
    end
    it 'returns a success response' do
      expect(response).to be_success
    end
    it 'assigns a line_pay_info instance' do
      expect(response.body).to include 'LinePay支払い情報設定'
    end
  end

  describe 'GET #edit' do
    before do
      get edit_line_pay_info_url line_pay_info.to_param
    end
    it 'returns a success response' do
      expect(response).to be_success
    end
    it 'assigns a line_pay_info' do
      expect(response.body).to include line_pay_info.channel_id
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) do
      {
        company: company,
        channel_id: Faker::Lorem.characters(20),
        channel_secret: Faker::Lorem.characters(20),
        enable_flg: true
      }
    end
    it 'creates a new LinePayInfo' do
      expect {
        post line_pay_info_url, params: { line_pay_info: valid_attributes }
      }.to change(LinePayInfo, :count).by(1)
    end

    it 'redirects to the created line_pay_info' do
      post line_pay_info_url, params: { line_pay_info: valid_attributes }
      expect(response).to \
        redirect_to(edit_line_pay_info_url LinePayInfo.last)
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
        id: line_pay_info.id,
        channel_id: Faker::Lorem.characters(20),
        channel_secret: plane_secret,
        enable_flg: true
      }
    end
    it 'is success to request' do
      put line_pay_info_url, params: { line_pay_info: new_attributes }
      expect(response.status).to eq 302
      expect(response).to \
        redirect_to(edit_line_pay_info_url line_pay_info)
    end
    it 'updates the requested line_pay_info' do
      put line_pay_info_url, params: {line_pay_info: new_attributes }
      expect(line_pay_info.reload.channel_id).to \
        eq(new_attributes[:channel_id])
      expect(@encryptor.decrypt(line_pay_info.channel_secret)).to \
        eq(@encryptor.decrypt(encrypted_secret))
    end
  end
end
