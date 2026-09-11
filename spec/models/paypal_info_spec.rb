require 'rails_helper'

RSpec.describe PaypalInfo, type: :model do
  create_sample_order
  describe "PaypalInfo#setup_gateway_information" do
    it "sets paypal gateway infos and creates gateway" do
      create(:paypal_info, company: company)
      encryptor = Encrypt.new
      gateway_information = PaypalInfo.new
      gateway_information.setup_gateway_information(cart.company)
      expect(gateway_information.gateway_login).to eq \
        encryptor.decrypt(company.paypal_info.paypal_credential_username)
      expect(gateway_information.gateway_password).to eq \
        encryptor.decrypt(company.paypal_info.paypal_credential_password)
      expect(gateway_information.signature).to eq \
        encryptor.decrypt(company.paypal_info.paypal_credential_signature)
      expect(gateway_information.gateway).to be_truthy
    end
  end
end
