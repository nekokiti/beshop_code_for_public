class AddJanCodeToOrderProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :order_products, :jancode, :string
  end
end
