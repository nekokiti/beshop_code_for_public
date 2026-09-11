class ChangeHasSizeToProduct < ActiveRecord::Migration[5.0]
  def up
    change_column :products, :has_size, :boolean, default: false
  end

  def down
    change_column :products, :has_size, :boolean
  end
end
