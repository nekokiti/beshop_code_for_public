class RemoveDeviseFromLineUser < ActiveRecord::Migration[5.0]
  def up
    remove_index :line_users, :reset_password_token
    remove_column :line_users, :encrypted_password
    remove_column :line_users, :reset_password_token
    remove_column :line_users, :reset_password_sent_at
    remove_column :line_users, :remember_created_at
    remove_column :line_users, :sign_in_count
    remove_column :line_users, :current_sign_in_at
    remove_column :line_users, :last_sign_in_at
    remove_column :line_users, :current_sign_in_ip
    remove_column :line_users, :last_sign_in_ip
  end
  def down
    add_index :line_users, :reset_password_token
    add_column :line_users, :encrypted_password
    add_column :line_users, :reset_password_token
    add_column :line_users, :reset_password_sent_at
    add_column :line_users, :remember_created_at
    add_column :line_users, :sign_in_count
    add_column :line_users, :current_sign_in_at
    add_column :line_users, :last_sign_in_at
    add_column :line_users, :current_sign_in_ip
    add_column :line_users, :last_sign_in_ip
  end
end
