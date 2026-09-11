class CreatePaypalInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :paypal_infos do |t|
      t.string :paypal_credential_username
      t.string :paypal_credential_password
      t.string :paypal_credential_signature
      t.integer :company_id

      t.timestamps
    end
  end
end
