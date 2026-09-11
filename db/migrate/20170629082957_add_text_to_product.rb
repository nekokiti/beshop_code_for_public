class AddTextToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :description, :string, limit: 60
  end
end
