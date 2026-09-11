class ChnageShippingNumberToShippingInfo < ActiveRecord::Migration[5.0]
  def change
    change_column :shipping_infos, :shipping_number, :string
  end
end
