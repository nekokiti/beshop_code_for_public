class AddDeletedAtToCarts < ActiveRecord::Migration[5.0]
  def change
    add_column :carts, :deleted_at, :datetime
    add_index :carts, :deleted_at
  end
end
