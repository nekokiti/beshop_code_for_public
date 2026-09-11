class CreateBusinessHours < ActiveRecord::Migration[5.0]
  def change
    create_table :business_hours do |t|
      t.datetime :open_time
      t.datetime :close_time
      t.integer :company_id
      t.timestamps
    end
  end
end
