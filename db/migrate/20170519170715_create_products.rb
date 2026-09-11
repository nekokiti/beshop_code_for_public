class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :name, null:false
      t.string :url, null:false
      t.string :image_path
      t.boolean :del_flg, default: false
      t.integer :company_id, null:false

      t.timestamps
    end
  end
end
