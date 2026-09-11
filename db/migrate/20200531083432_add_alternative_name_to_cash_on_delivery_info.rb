class AddAlternativeNameToCashOnDeliveryInfo < ActiveRecord::Migration[5.0]
  def change
    add_column :cash_on_delivery_infos, :alternative_name, :string, default: nil
  end
end
