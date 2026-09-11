class CreateSticons < ActiveRecord::Migration[5.0]
  def change
    create_table :sticons do |t|
      t.integer :sticon_id
      t.integer :sticonpackage_id

      t.timestamps
    end
  end
end
