class AddUrlToTag < ActiveRecord::Migration[5.0]
  def change
    add_column :tags, :url, :string
  end
end
