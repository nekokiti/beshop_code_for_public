class CreateShippingCompanies < ActiveRecord::Migration[5.0]
  def change
    create_table :shipping_companies do |t|
      t.references :company, foreign_key: true
      t.string :name, null: false
      t.timestamps
    end
  end
end
