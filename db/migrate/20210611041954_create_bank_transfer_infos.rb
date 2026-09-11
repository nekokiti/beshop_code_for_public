class CreateBankTransferInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :bank_transfer_infos do |t|
      t.boolean :enable_flg, null: false, default: false
      t.references :company, foreign_key: true

      t.timestamps
    end
  end
end
