class AddJanCodeToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :jancode, :string
  end
end
