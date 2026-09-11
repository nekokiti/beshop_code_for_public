class AddPayeridToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :payer_id, :integer
  end
end
