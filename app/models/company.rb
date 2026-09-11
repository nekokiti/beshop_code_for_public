class Company < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :products
  has_many :orders
  has_many :tags
  has_many :shipping_companies, dependent: :destroy
  has_many :line_users, dependent: :destroy

  has_one :paypal_info, dependent: :destroy
  has_one :line_pay_info, dependent: :destroy
  has_one :pay_pay_info, dependent: :destroy
  has_one :paidy_info, dependent: :destroy
  has_one :cash_on_delivery_info, dependent: :destroy
  has_one :bank_transfer_info, dependent: :destroy
  has_one :line_auth_info, dependent: :destroy
  has_one :shipping, dependent: :destroy
  has_one :business_hour, dependent: :destroy
  has_one :minimum_price, dependent: :destroy
  has_one :extra_message, dependent: :destroy
  has_one :company_reserve, dependent: :destroy

  belongs_to :occupation_mst
  # ↓恐らくいらない
  accepts_nested_attributes_for :paypal_info
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable
  validates :company_name, presence: true

  attr_accessor :gateway_login, :gateway_password, :signature

  def check_email(receiver_email)
    paypal_info.email_id == receiver_email
  end

  def self.get_company_with_uuid(uuid)
    res = select(
      'id', 'channel_access_token', 'channel_secret', 'occupation_mst_id'
    ).where(
      unique_id: uuid
    ).first
    res.channel_secret = res.decrypt_channel_secret
    res
  end

  def encrypt_channel_secret(secret_key)
    encryptor = Encrypt.new
    encryptor.encrypt(secret_key)
  end

  def decrypt_channel_secret
    encryptor = Encrypt.new
    encryptor.decrypt(channel_secret)
  end

  def cash_on_delivery_info_display_name
    cash_on_delivery_info.alternative_name.blank? ?  "代引き払い" : cash_on_delivery_info.alternative_name
  end

end
