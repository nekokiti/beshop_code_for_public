class LineAuthInfo < ApplicationRecord
  belongs_to :company

  validates :channel_id, presence: true
  validates :channel_secret, presence: true

  def self.my_line_auth_info(current_company)
    find_by(company: current_company)
  end

  def save_with_encrypt
    encryptor = Encrypt.new
    self.channel_secret = \
      encryptor.encrypt(channel_secret)
    save
  end

  def update_with_encrypt(params)
    encryptor = Encrypt.new
    params[:channel_secret] = \
      encryptor.encrypt(params[:channel_secret])
    update(params)
  end

  def decrypt_keys
    encryptor = Encrypt.new
    self.channel_secret = \
      encryptor.decrypt(channel_secret)
  end
end
