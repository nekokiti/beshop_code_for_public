class CreatePaidyInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :paidy_infos do |t|
      t.references :company, foreign_key: true
      t.string :public_key
      t.string :secret_key
      t.boolean :enable_flg, null: false, default: false

      t.timestamps
    end
  end
end
