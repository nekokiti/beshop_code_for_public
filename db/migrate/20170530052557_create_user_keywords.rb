class CreateUserKeywords < ActiveRecord::Migration[5.0]
  def change
    create_table :user_keywords do |t|
      t.string :keyword, null: false

      t.timestamps
    end
  end
end
