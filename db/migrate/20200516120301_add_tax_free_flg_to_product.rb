class AddTaxFreeFlgToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :tax_free_flg, :boolean, default: false
  end
end
