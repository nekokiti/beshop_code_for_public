require 'rails_helper'

RSpec.describe Companies::RegistrationsController, type: :request do
  login_company
  describe 'GET #edit' do
    before do
      get edit_company_registration_url
    end
    it 'returns a success response' do
      expect(response).to be_success
      expect(controller.company_signed_in?).to be_truthy
    end
    it 'assigns a company' do
      expect(response.body).to include controller.current_company.email
    end
  end
  describe 'GET #update' do
    let(:new_attributes) do {
      channel_secret: Faker::Lorem.characters(20),
      channel_access_token: Faker::Lorem.characters(50),
      current_password: company.password
    }
    end
    it "updates the company profile" do
      put company_registration_url, params: {company: new_attributes }
      expect(company.reload.channel_access_token).to \
        eq(new_attributes[:channel_access_token])
      expect(company.decrypt_channel_secret).to \
        eq(new_attributes[:channel_secret])
      expect(response.location).to \
        include(edit_company_registration_path)
    end
  end
end
