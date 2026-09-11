class CreateExtraMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :extra_messages do |t|
      t.references :company, foreign_key: true
      t.string :extra_message
      t.timestamps
    end
  end
end
