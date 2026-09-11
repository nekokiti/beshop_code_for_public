class AddRoomNumberToOrder < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :room_number, :string, default: '未設定'
  end
end
