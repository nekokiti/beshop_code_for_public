class AddReductionTaxFlgToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :reduction_tax, :boolean, default: false
  end
end
