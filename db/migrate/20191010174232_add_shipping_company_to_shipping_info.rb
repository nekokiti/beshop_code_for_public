class AddShippingCompanyToShippingInfo < ActiveRecord::Migration[5.0]
  def change
    add_reference :shipping_infos, :shipping_company, foreign_key: true
  end
end
