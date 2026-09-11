require 'rails_helper'

RSpec.describe PaypalInfosController, type: :request do
  login_company
  let(:paypal_info) { create(:paypal_info, company: company) }
  let(:encrypter) { Encrypt.new }

  describe "GET #new" do
    before do
      get new_paypal_info_url, params: {}
    end
    it "returns a success response" do
      expect(response).to be_success
    end
    it "assigns a paypal_info instance" do
      expect(response.body).to include "Paypal情報設定"
    end
  end

  describe "GET #edit" do
    before do
      get edit_paypal_info_url paypal_info.to_param
    end
    it "returns a success response" do
      expect(response).to be_success
    end
    it "assigns a paypal_info" do
      expect(response.body).to include \
        encrypter.decrypt(paypal_info.paypal_credential_username)
    end
  end

  describe "POST #create" do
    let(:valid_attributes) do
      {
        company: company,
        paypal_credential_username: Faker::Internet.email,
        paypal_credential_password: Faker::Internet.password(8),
        paypal_credential_signature: Faker::Lorem.characters(20),
        email_id: Faker::Internet.email,
        enable_flg: true
      }
    end
    it "creates a new PaypalInfos" do
      expect {
        post paypal_info_url, params: {paypal_info: valid_attributes}
      }.to change(PaypalInfo, :count).by(1)
    end

    it "redirects to the created paypal_info" do
      post paypal_info_url, params: {paypal_info: valid_attributes}
      expect(response).to redirect_to(edit_paypal_info_url PaypalInfo.last)
    end
  end

  describe "PUT #update" do
    let(:new_attributes) do {
      id: paypal_info.id,
      paypal_credential_username: Faker::Internet.email,
      paypal_credential_password: Faker::Internet.password(8),
      paypal_credential_signature: Faker::Lorem.characters(20),
      email_id: Faker::Internet.email,
      enable_flg: true
    }
    end
    it "is success to request" do
      put paypal_info_url, params: { paypal_info: new_attributes }
      expect(response.status).to eq 302
      expect(response).to redirect_to edit_paypal_info_url paypal_info
    end
    it "updates the requested paypal_info" do
      put paypal_info_url, params: { paypal_info: new_attributes }
      expect(
        encrypter.decrypt(paypal_info.reload.paypal_credential_username)
      ).to eq(new_attributes[:paypal_credential_username])
      expect(encrypter.decrypt(paypal_info.paypal_credential_password)).to \
        eq(new_attributes[:paypal_credential_password])
      expect(encrypter.decrypt(paypal_info.paypal_credential_signature)).to \
        eq(new_attributes[:paypal_credential_signature])
      expect(paypal_info.email_id).to \
        eq(
          new_attributes[:email_id]
        )
    end
  end

end
