module AuthenticationMacros
  def login_company
    let(:company) { create(:company) }
    before do
      sign_in company
    end
  end
end
