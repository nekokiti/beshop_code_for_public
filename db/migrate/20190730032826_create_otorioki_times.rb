class CreateOtoriokiTimes < ActiveRecord::Migration[5.0]
  def change
    create_table :otorioki_times do |t|
      t.integer :min_time
      t.timestamps
    end
  end
end
