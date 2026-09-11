FactoryBot.define do
  encryptor = Encrypt.new
  plain_secret = 'sk_test_eo57cm03maecnpr84geo6plo6i'
  encrypted_secret = encryptor.encrypt(plain_secret)
  factory :paidy_info do
    public_key { 'pk_test_ufmgs00f816c2bqvr528m6csjt' }
    secret_key { encrypted_secret }
    enable_flg { true }
    company
  end
end
