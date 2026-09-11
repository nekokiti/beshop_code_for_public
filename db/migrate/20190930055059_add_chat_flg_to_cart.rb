class AddChatFlgToCart < ActiveRecord::Migration[5.0]
  def change
    add_column :carts, :chat_mode_flg, :boolean, default: false
  end
end
