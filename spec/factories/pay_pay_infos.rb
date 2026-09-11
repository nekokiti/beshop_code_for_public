FactoryBot.define do
  #circle_ci上のテストを通すため、サンドボックス用の値を設定
  encryptor = Encrypt.new
  plain_secret = '3TttFLZSBLLMs1PcjJFZPqEG+0G4jR3cST4w3j8t'
  encrypted_secret = encryptor.encrypt(plain_secret)
  factory :pay_pay_info do
    client_id { 'm_RfCd6QK6H5_GjI1' }
    client_secret { encrypted_secret }
    merchant_id { '285101522763956224' }
    enable_flg { true }
    company
  end
end
