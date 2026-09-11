class AddRoomNoToLineUser < ActiveRecord::Migration[5.0]
  def change
    add_column :line_users, :room_number, :string, default: nil
  end
end
