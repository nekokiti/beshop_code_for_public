class AddImagePathToTag < ActiveRecord::Migration[5.0]
  def change
    add_column :tags, :image_path, :string
  end
end
