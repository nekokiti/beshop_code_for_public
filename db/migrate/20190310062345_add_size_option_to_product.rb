class AddSizeOptionToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :has_size, :boolean
  end
end
