class AddColumnGroupKeyToGottenProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :gotten_products, :group_key, :string, null:false
  end
end
