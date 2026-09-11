require 'rails_helper'

RSpec.describe CartProduct, type: :model do
  #Sサイズはcreate_sample_orderで購入している
  create_sample_order

  describe "CartProduct#product_quantity" do
    it "gets quantity of cart_product" do

      CartProduct.update_cart_product(cart, products.first.id, 2)
      q = CartProduct.product_quantity(cart, products.first)
      expect(q).to eq 2

      q = CartProduct.product_quantity(
        cart,
        products_has_size.first.id,
        Size::S
      )
      expect(q).to eq 1

    end
  end

  describe "CartProduct#check_already_had" do
    it "checks the product is already exists in cart_product" do
      res = CartProduct.check_already_had?(
        cart,
        products_has_size.first.id,
        Size::S
      )
      expect(res).to be_truthy
      res = CartProduct.check_already_had?(
        cart,
        products_has_size.first.id,
        Size::M
      )
      expect(res).to be_falsey
    end
  end

  describe "update_cart_product" do
    it "create cart products with size" do
      cart_product = CartProduct.find_by(
        cart_id: cart.id,
        product_id: products_has_size.first.id
      )
      expect(cart_product.size).to eq Size.find(Size::S)
    end
    it "updates quantity of items" do
      CartProduct.update_cart_product(cart, products.first.id, 3)
      cart_product = CartProduct.find_by(
        cart_id: cart.id,
        product_id:
        products.first.id
      )
      expect(cart_product.quantity).to eq 3
    end
  end

  describe "del_cart_products" do
    context "the items are exist" do
      it "removes product in the cart" do
        cart.cart_products.each do |cart_product|
          expect(CartProduct.del_cart_products(cart_product.id)).to \
            eq '商品を削除しました'
        end
      end
    end
    context "the items are not exist" do
      it "does not remove product in the cart" do
        expect(CartProduct.del_cart_products(1)).to eq '商品がありません'
      end
    end
  end
end
