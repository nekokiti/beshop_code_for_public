FactoryBot.define do
  encryptor = Encrypt.new
  plain_paypal_credential_username = Faker::Internet.email
  plain_paypal_credential_passwrd = Faker::Internet.password(8)
  plain_paypal_credential_signature = Faker::Lorem.characters(20)
  encrypted_credential_username = \
    encryptor.encrypt(plain_paypal_credential_username)
  encrypted_credential_passwrd = \
    encryptor.encrypt(plain_paypal_credential_passwrd)
  encrypted_credential_signature = \
    encryptor.encrypt(plain_paypal_credential_signature)
  factory :paypal_info do
    paypal_credential_username { encrypted_credential_username }
    paypal_credential_password { encrypted_credential_passwrd }
    paypal_credential_signature { encrypted_credential_signature }
    email_id { Faker::Internet.email }
    enable_flg { true }
    company
  end
end
