class AddCouponFlgToProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :coupon_flg, :boolean, default: false
  end
end
