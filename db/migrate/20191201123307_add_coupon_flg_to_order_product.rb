class AddCouponFlgToOrderProduct < ActiveRecord::Migration[5.0]
  def change
    add_column :order_products, :coupon_flg, :boolean, default: false
  end
end
