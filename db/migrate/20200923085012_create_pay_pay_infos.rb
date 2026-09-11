class CreatePayPayInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :pay_pay_infos do |t|
      t.string :client_id
      t.string :client_secret
      t.string :merchant_id
      t.boolean :enable_flg, null: false, default: false
      t.references :company, foreign_key: true

      t.timestamps
    end
  end
end
