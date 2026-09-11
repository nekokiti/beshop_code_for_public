require 'rails_helper'

RSpec.describe 'CheckMail' do
  let(:email) { 'test@gmail.com' }
  let(:not_email) { '不要' }
  describe 'check' do
    it 'check email address' do
      expect(CheckMail.check(email: email)).to be_truthy
      expect(CheckMail.check(email: not_email)).to be_falsey
    end
  end
end
