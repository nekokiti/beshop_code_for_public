class RemoveShippingCompanyNameFromShippingInfo < ActiveRecord::Migration[5.0]
  def up
    remove_column :shipping_infos, :shipping_company
  end
  def down
    add_column :shipping_infos, :shipping_company, :string
  end
end
