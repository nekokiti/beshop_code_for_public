class DeleteGottenProducts < ActiveRecord::Migration[5.0]
  def change
    drop_table :gotten_products
  end
end
