class AddLineUserIdToGottenProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :gotten_products, :line_user_id, :integer
  end
end
