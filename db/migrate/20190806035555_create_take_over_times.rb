class CreateTakeOverTimes < ActiveRecord::Migration[5.0]
  def change
    create_table :take_over_times do |t|
      t.datetime :take_over_time, null: false
      t.references :cart, foreign_key: true
      t.timestamps
    end
  end
end
