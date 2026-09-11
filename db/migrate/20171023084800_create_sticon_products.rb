class CreateSticonProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :sticon_products do |t|
      t.references :sticon, foreign_key: true
      t.references :product, foreign_key: true

      t.timestamps
    end
  end
end
