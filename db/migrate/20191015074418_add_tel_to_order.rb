class AddTelToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :tel, :string
  end
end
