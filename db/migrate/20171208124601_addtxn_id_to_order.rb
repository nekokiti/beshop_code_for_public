class AddtxnIdToOrder < ActiveRecord::Migration[5.0]
  def change
		add_column :orders, :txn_id, :string
  end
end
