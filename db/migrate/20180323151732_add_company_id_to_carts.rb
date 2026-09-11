class AddCompanyIdToCarts < ActiveRecord::Migration[5.0]
  def change
    add_column :carts, :company_id, :integer
    add_column :carts, :cart_hash, :string
  end
end
