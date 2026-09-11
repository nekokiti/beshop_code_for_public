class CreatePaidyCaptures < ActiveRecord::Migration[5.2]
  def change
    create_table :paidy_captures do |t|
      t.string :capture_id
      t.references :order, foreign_key: true

      t.timestamps
    end
  end
end
