class PaidyInfo < ApplicationRecord
  belongs_to :company

  validates :public_key, presence: true
  validates :secret_key, presence: true

  def self.my_paidy_info(current_company)
    find_by(company: current_company)
  end

  def save_with_encrypt
    encryptor = Encrypt.new
    self.secret_key = \
      encryptor.encrypt(secret_key)
    save
  end

  def update_with_encrypt(params)
    encryptor = Encrypt.new
    params[:secret_key] = \
      encryptor.encrypt(params[:secret_key])
    update(params)
  end

  def decrypt_keys
    encryptor = Encrypt.new
    self.secret_key = \
      encryptor.decrypt(secret_key)
  end
end
