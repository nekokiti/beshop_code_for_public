require 'rails_helper'

RSpec.configure do |config|
#  config.use_transactional_fixtures = false
end

RSpec.describe Company, :type => :model do
  let(:before_encrypt_key) { 'my_key' }
  let(:company) { create(:company, channel_secret: before_encrypt_key) }
  describe "check_email" do
    it "checks emall" do
      paypal_info = create(:paypal_info, company: company)
      expect(company.check_email(paypal_info.email_id)).to be_truthy
    end
  end
  describe "encrypt_channel_secret" do
    it "encrypts channel secret" do
      expect(company.channel_secret).not_to eq before_encrypt_key
    end
    it "decrypts channel secret" do
      expect(company.decrypt_channel_secret).to eq before_encrypt_key
    end
  end
  describe "get_company_with_uuid" do
    it "gets company with uuid" do
      res = Company.get_company_with_uuid(company.unique_id)
      expect(res).to eq company
      expect(res.channel_secret).to eq before_encrypt_key
    end
  end
  describe "cash_on_delivery_info_display_name" do
    let!(:cash_on_delivery_info) { create(:cash_on_delivery_info, company: company, price: 500) }
    context 'dosen not have an alternative_name' do
      it "returns default name" do
        res = company.cash_on_delivery_info_display_name
        expect(res).to eq '代引き払い'
      end
    end
    context 'has an alternative_name' do
      it "returns alternative_name" do
        company.cash_on_delivery_info.update!(alternative_name: "銀行振り込み")
        res = company.cash_on_delivery_info_display_name
        expect(res).to eq '銀行振り込み'
      end
    end
  end
end
