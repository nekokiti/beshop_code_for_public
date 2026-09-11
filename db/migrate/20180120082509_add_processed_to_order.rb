class AddProcessedToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :processed, :boolean, default: false
  end
end
