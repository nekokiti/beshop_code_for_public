class CreateLineAuthInfos < ActiveRecord::Migration[5.0]
  def change
    create_table :line_auth_infos do |t|
      t.string :channel_id
      t.string :channel_secret
      t.references :company, foreign_key: true

      t.timestamps
    end
  end
end
