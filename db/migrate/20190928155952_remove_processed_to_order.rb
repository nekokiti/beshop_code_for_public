class RemoveProcessedToOrder < ActiveRecord::Migration[5.0]
  def up
    remove_column :orders, :processed
  end
  def down
    add_column :orders, :processed, :boolean, default: false
  end
end
