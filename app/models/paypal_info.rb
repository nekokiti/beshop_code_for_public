class PaypalInfo < ApplicationRecord
  belongs_to :company

  validates :paypal_credential_username, presence: true
  validates :paypal_credential_password, presence: true
  validates :email_id, presence: true
  validates :paypal_credential_signature, presence: true
  attr_reader :gateway_login, :gateway_password, :signature

  def self.my_paypal_info(current_company)
    find_by(company: current_company)
  end

  def save_with_encrypt
    encryptor = Encrypt.new
    self.paypal_credential_username = \
      encryptor.encrypt(paypal_credential_username)
    self.paypal_credential_password = \
      encryptor.encrypt(paypal_credential_password)
    self.paypal_credential_signature = \
      encryptor.encrypt(paypal_credential_signature)
    save
  end

  def update_with_encrypt(params)
    encryptor = Encrypt.new
    params[:paypal_credential_username] = \
      encryptor.encrypt(params[:paypal_credential_username])
    params[:paypal_credential_password] = \
      encryptor.encrypt(params[:paypal_credential_password])
    params[:paypal_credential_signature] = \
      encryptor.encrypt(params[:paypal_credential_signature])
    update(params)
  end

  def decrypt_keys
    encryptor = Encrypt.new
    self.paypal_credential_username = \
      encryptor.decrypt(paypal_credential_username)
    self.paypal_credential_password = \
      encryptor.decrypt(paypal_credential_password)
    self.paypal_credential_signature = \
      encryptor.decrypt(paypal_credential_signature)
  end

  def setup_gateway_information(company)
    encryptor = Encrypt.new
    @gateway_login = encryptor.decrypt(
      company.paypal_info.paypal_credential_username
    )
    @gateway_password = encryptor.decrypt(
      company.paypal_info.paypal_credential_password
    )
    @signature = encryptor.decrypt(
      company.paypal_info.paypal_credential_signature
    )
  end

  def gateway
    ActiveMerchant::Billing::PaypalExpressGateway.new(
      login: @gateway_login,
      password: @gateway_password,
      signature: @signature
    )
  end
end
