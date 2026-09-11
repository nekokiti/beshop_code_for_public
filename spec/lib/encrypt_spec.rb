require 'rails_helper'

RSpec.describe 'Encrypt' do
  let(:message) { 'Hello!Word' }
  describe 'Encrypt# encrypt and #decrypt' do
    it 'encrypts and decrypts' do
      encryptor = Encrypt.new
      encrypted_message = encryptor.encrypt(message)
      expect(encrypted_message).not_to match message
      expect(encryptor.decrypt(encrypted_message)).to match message
    end
  end
end
