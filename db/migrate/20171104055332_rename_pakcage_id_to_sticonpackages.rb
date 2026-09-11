class RenamePakcageIdToSticonpackages < ActiveRecord::Migration[5.0]
  def change
		rename_column :sticonpackages, :pacage_id, :package_id
  end
end
