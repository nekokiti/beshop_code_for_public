class CreateLineUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :line_users do |t|
      t.string :line_id, null: false

      t.timestamps
    end
  end
end
