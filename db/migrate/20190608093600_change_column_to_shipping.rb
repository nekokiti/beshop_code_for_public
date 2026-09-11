class ChangeColumnToShipping < ActiveRecord::Migration[5.0]
  def up
    change_column :shippings, :shipping_fee, :integer, default: 0
    change_column :shippings, :extra_fee, :integer, default: 0
  end

  def down
    change_column :shippings, :shipping_fee, :integer
    change_column :shippings, :extra_fee, :integer
  end
end
