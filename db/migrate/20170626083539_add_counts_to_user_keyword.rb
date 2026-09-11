class AddCountsToUserKeyword < ActiveRecord::Migration[5.0]
  def change
    add_column :user_keywords, :counts, :integer, default: 1
  end
end
