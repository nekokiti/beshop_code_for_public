class Shipping < ApplicationRecord
  belongs_to :company

  def self.my_shipping_info(current_company)
    self.find_by(company: current_company)
  end

end
