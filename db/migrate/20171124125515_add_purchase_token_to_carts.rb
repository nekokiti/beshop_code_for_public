class AddPurchaseTokenToCarts < ActiveRecord::Migration[5.0]
  def change
    add_column :carts, :token, :string
  end
end
