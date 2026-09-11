class AddProductIdToOtoriokiTime < ActiveRecord::Migration[5.0]
  def change
    add_column :otorioki_times, :product_id, :integer
  end
end
