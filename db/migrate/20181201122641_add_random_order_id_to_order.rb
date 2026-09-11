class AddRandomOrderIdToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :random_order_id, :string
  end
end
