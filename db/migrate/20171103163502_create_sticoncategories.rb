class CreateSticoncategories < ActiveRecord::Migration[5.0]
  def change
    create_table :sticoncategories do |t|
      t.string :name

      t.timestamps
    end
  end
end
