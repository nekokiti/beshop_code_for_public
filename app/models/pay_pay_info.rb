class PayPayInfo < ApplicationRecord
  belongs_to :company

  validates :client_id, presence: true
  validates :client_secret, presence: true
  validates :merchant_id, presence: true

  def self.my_pay_pay_info(current_company)
    find_by(company: current_company)
  end

  def save_with_encrypt
    encryptor = Encrypt.new
    self.client_secret = \
      encryptor.encrypt(client_secret)
    save
  end

  def update_with_encrypt(params)
    encryptor = Encrypt.new
    params[:client_secret] = \
      encryptor.encrypt(params[:client_secret])
    update(params)
  end

  def decrypt_keys
    encryptor = Encrypt.new
    self.client_secret = \
      encryptor.decrypt(client_secret)
  end
end
