class CreateReserveDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :reserve_details do |t|
      t.references :line_user, foreign_key: true
      t.references :order, foreign_key: true
      t.references :cart, foreign_key: true
      t.date :take_over_date
      t.time :take_over_time_from
      t.time :take_over_time_to
      t.timestamps
    end
  end
end
