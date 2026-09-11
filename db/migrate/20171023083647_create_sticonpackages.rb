class CreateSticonpackages < ActiveRecord::Migration[5.0]
  def change
    create_table :sticonpackages do |t|
      t.integer :pacage_id

      t.timestamps
    end
  end
end
