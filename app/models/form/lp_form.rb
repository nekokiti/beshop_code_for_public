class Form::LpForm
  include ActiveModel::Model

  attr_accessor :name, :email, :tel, :willing, :is_company

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_PHONE_REGEX = /\A\d{10}$|^\d{11}\z/

  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }
  validates :name, presence: true
  validates :tel, allow_blank: true, format: { with: VALID_PHONE_REGEX }
  validates :is_company, presence: true

end

