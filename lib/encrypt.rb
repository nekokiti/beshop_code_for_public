class Encrypt
  def initialize
    secret = Rails.application.secrets.secret_key_base.slice(0..31)
    @encryptor = ::ActiveSupport::MessageEncryptor.new(
      secret, cipher: 'aes-256-cbc'
    )
  end

  def encrypt(message)
    @encryptor.encrypt_and_sign(message)
  end

  def decrypt(encrypt_message)
    @encryptor.decrypt_and_verify(encrypt_message)
  end
end
