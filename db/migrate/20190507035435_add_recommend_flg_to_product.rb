class AddRecommendFlgToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :recommend_flg, :boolean, default: false
  end
end
