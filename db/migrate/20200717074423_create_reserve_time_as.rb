class CreateReserveTimeAs < ActiveRecord::Migration[5.0]
  def change
    create_table :reserve_time_as do |t|
      t.references :company, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.time :from_time_1
      t.time :end_time_1
      t.time :from_time_2
      t.time :end_time_2
      t.timestamps
    end
  end
end
