FactoryBot.define do
  #circle_ci上のテストを通すため、サンドボックス用の値を設定
  encryptor = Encrypt.new
  plain_secret = '714e87b0e170f7daef056401147734fb'
  encrypted_secret = encryptor.encrypt(plain_secret)
  factory :line_pay_info do
    channel_id { '1620665766' }
    channel_secret { encrypted_secret }
    enable_flg { true }
    company
  end
end
