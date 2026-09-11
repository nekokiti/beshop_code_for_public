require 'rails_helper'

RSpec.describe OmniauthCallbacksController, type: :request do
  let(:company) { create(:company) }
  let!(:line_auth_info) { create(:line_auth_info, company: company) }

  describe 'auth_require' do
    it 'do not call an error' do
      res = get omniauth_line_require_url(company_id: company.unique_id)
      expect(res).to eq 204
    end
  end

  describe 'get_auth_code' do
    it 'returns a success response' do
      res = get omniauth_get_auth_code_url(company_id: company.unique_id, code: "abcd12345")
      expect(res).to eq 302
      expect(res).to_not eq 500
    end
  end

end
