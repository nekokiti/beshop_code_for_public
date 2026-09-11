class ShippingCompany < ApplicationRecord
  belongs_to :company
  has_many :shipping_infos
  scope :my_shipping_companies, ->(current_company) { where(company: current_company).order(:id) }
end
