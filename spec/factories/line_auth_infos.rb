FactoryBot.define do
  encryptor = Encrypt.new
  plain_secret = "#{Faker::Lorem.characters(8)}"
  encrypted_secret = encryptor.encrypt(plain_secret)
  factory :line_auth_info do
    channel_id { Faker::Lorem.characters(8) }
    channel_secret { encrypted_secret }
    company
  end
end
