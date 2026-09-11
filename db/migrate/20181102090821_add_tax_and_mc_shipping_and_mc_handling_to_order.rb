class AddTaxAndMcShippingAndMcHandlingToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :tax, :integer
    add_column :orders, :mc_shipping, :integer
    add_column :orders, :mc_handling, :integer
  end
end
