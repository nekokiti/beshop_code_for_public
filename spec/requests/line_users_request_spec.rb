require 'rails_helper'

RSpec.describe 'LineUsers', type: :request do
  create_sample_order
  login_company
  describe "push" do
    let(:valid_attributes) do
      {
        product_ids: [products.first.id],
        id: line_user.id
      }
    end
    it "push template messages" do
      res = post line_user_push_url, params: { form_push_with_product_form: valid_attributes }
      expect(res).to eq 302
    end
  end
end
