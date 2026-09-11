require 'rails_helper'

RSpec.describe Payments::CommonController, type: :request do
  create_sample_order
  describe "order_complete" do
    it "redirects to order_detail" do
      get payments_common_complete_url order.cart.cart_hash
      expect(response.status).to eq 302
    end
  end
  describe "order_details" do
    it "renders order_details view" do
      order.txn_id = 'test_txn_id'
      OrderProduct.create_order_product(order, order.cart)
      Product.decrement_inventory(order.cart)
      order.verify('test_txn_id')
      order.set_address_with_line_pay
      order.cart.destroy!
      get payments_common_order_detail_url cart.cart_hash
      expect(response.status).to eq 200
    end
  end
  describe "inventory_error" do
    # カート内にはサイズ無し、Sサイズ、Mサイズ商品が各3ずつ計9つ入っている
    # (SとMは同じ商品のサイズ違い)
    it "returns inventory error page and del products in cart" do
      # サイズ無しの商品の内1つ目の商品の在庫を0にする
      products.first.update(quantity: 0)
      # サイズ無しの商品の内2つ目の商品を3つカートに入れ、その後在庫を2つにする(在庫切れ状態にする)
      CartProduct.update_cart_product(cart, products.second.id, 3)
      products.second.update(quantity: 2)

      products_has_size.each do |product|
        CartProduct.update_cart_product(cart, product.id, 1, Size::M)

        # サイズ有り商品の内、Sサイズの商品の在庫を5にする
        size_product_s = SizeProduct.releated_size(product, Size.find(Size::S))
        size_product_s.update_attribute(:quantity, 5)

        # サイズ有り商品の内、Mサイズの商品の在庫を0にする
        size_product_m = SizeProduct.releated_size(product, Size.find(Size::M))
        size_product_m.update_attribute(:quantity, 0)
      end

      get payments_common_inventory_error_url cart.cart_hash
      expect(response.status).to eq 200
      expect(response.body).to include products.first.name
      expect(response.body).to include products.second.name
      # 在庫0の商品であればカート自体(cart_products中間テーブル)を削除する
      expect(cart.cart_products.find_by(product_id: products.first.id)).to eq nil
      expect(cart.cart_products.where(size_id: Size::M).size.positive?).to be_falsy
      # 購入希望数 > 在庫数 であればカートの中身は削除しない
      expect(cart.cart_products.find_by(product_id: products.second.id)).not_to eq nil
      expect(cart.cart_products.where(size_id: Size::S).size.positive?).to be_truthy
    end
  end
end
