class CreateReserveTimeBs < ActiveRecord::Migration[5.0]
  def change
    create_table :reserve_time_bs do |t|
      t.references :company, foreign_key: true
      t.integer :days_after_from
      t.integer :days_after_to
      t.time :from_time_1
      t.time :end_time_1
      t.time :from_time_2
      t.time :end_time_2
      t.timestamps
    end
  end
end
