class AddSticoncategoryIdToSticonpackage < ActiveRecord::Migration[5.0]
  def change
    add_column :sticonpackages, :sticoncategory_id, :integer
  end
end
