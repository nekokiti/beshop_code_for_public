class AddOrderIdToTakeOverTimes < ActiveRecord::Migration[5.0]
  def change
    add_column :take_over_times, :order_id, :integer
  end
end
