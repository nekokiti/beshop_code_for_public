require 'rails_helper'

RSpec.describe Cart, type: :model do
  let(:user) { create(:line_user) }
  let(:company) { create(:company) }
  let!(:shipping) { create(:shipping, company: company) }
  let(:products) {
    products = []
    15.times do
      products << create(:product, company: company)
    end
    products
  }
  let(:products_for_take_out) do
    products = []
    3.times do
      res = create(:product,
                   company: company,
                   otorioki_flg: true)
      create(:otorioki_time, product: res, min_time: 30)
      products << res
    end
    products
  end
  let(:products_has_no_extra_fee) do
    create(:product, company: company, no_extra_fee: true)
  end
  let(:products_has_size) do
    products = []
    10.times do
      products << create(:product,
                         has_size: true,
                         company: company,
                         sizes: Size.all)
    end
    products
  end

  describe "Cart#out_of_inventory" do
    it "returns products of out of inventory" do
      cart = Cart.create_cart(user, company)

      cart.add_cart(products[0].id, 1)
      cart.add_cart(products[1].id, 1)
      cart.add_cart(products_has_size[0].id, 1, Size::M)

      products[0].update!(quantity: 0)
      products_has_size[0].update!(quantity: 0)

      remove_1 = cart.cart_products.find_by(product_id: products[0].id)
      remove_2 = cart.cart_products.find_by(product_id: products_has_size[0].id)
      not_remove_1 = cart.cart_products.find_by(product_id: products[1].id)

      out_of_inventory = Cart.out_of_inventory(cart)
      expect(out_of_inventory).to include remove_1
      expect(out_of_inventory).to include remove_2
      expect(out_of_inventory).not_to include not_remove_1
    end
  end

  describe "need_extra_fee?" do
    before do
      @cart = Cart.create_cart(user, company)
    end
    it "needs extra fee" do
      @cart.add_cart(products[0].id, 1)
      @cart.add_cart(products_has_no_extra_fee.id, 1)
      expect(@cart.need_extra_fee?).to be_truthy
    end
    it "doesn't need extra fee" do
      @cart.add_cart(products_has_no_extra_fee.id, 1)
      expect(@cart.need_extra_fee?).to be_falsy
    end
  end

  describe "calc price of products in cart" do
    before do
      @cart = Cart.create_cart(user, company)
    end
    describe "Cart#calc_total_products_price_in_cart" do
      it "without shipping and handling" do
        @price_without_tax = 0
        5.times do | i |
          @cart.add_cart(products[i].id, 1)
          @price_without_tax += products[i].price
        end
        expect(@price_without_tax).to eq @cart.calc_total_products_price_in_cart_without_tax
      end
    end
    describe "Cart#calc_total_price_in_cart" do
      it "with shipping and handling" do
        @price_with_tax = 0
        5.times do | i |
          @cart.add_cart(products[i].id, 1)
          @price_with_tax += products[i].calc_price_with_tax
        end
        total = @price_with_tax +
                company.shipping.shipping_fee.to_i +
                company.shipping.extra_fee
        expect(total).to eq @cart.calc_total_price_in_cart
      end
    end
  end

  describe "create_cart" do
    context "初めてそのユーザーが対象の会社にカートを作る場合" do
      it "gets cart" do
        cart = Cart.create_cart(user, company)
        expect(cart).to be_truthy
      end
    end
    context "対象のユーザーが既にその会社でカートを作っている場合" do
      it "does not create cart and gets own cart" do
        cart_a = Cart.create_cart(user, company)
        cart_b = Cart.create_cart(user, company)
        expect(cart_a).to eq cart_b
      end
    end
  end
  describe "get_my_cart" do
    it "gets my cart" do
      cart_a = Cart.create_cart(user, company)
      cart_b = Cart.get_my_cart(user, company)
      expect(cart_b).to be_truthy
      expect(cart_a).to eq cart_b
    end
  end
  describe "get_cart_by_hash" do
    it "finds cart by cart_hash" do
      cart_a = Cart.create_cart(user, company)
      cart_b = Cart.get_cart_by_hash(cart_a.cart_hash)
      expect(cart_a).to eq cart_b
    end
  end
  describe "get_cart_by_hash_with_deleted" do
    it "finds cart by cart_hash even if it was deleted" do
      cart_a = Cart.create_cart(user, company)
      cart_a.destroy
      cart_b = Cart.get_cart_by_hash_with_deleted(cart_a.cart_hash)
      expect(cart_a).to eq cart_b
    end
  end
  describe "get_cart_by_id_with_deleted" do
    it "finds cart by id even if it was deleted" do
      cart_a = Cart.create_cart(user, company)
      cart_a.destroy
      cart_b = Cart.get_cart_by_id_with_deleted(cart_a.id)
      expect(cart_a).to eq cart_b
    end
  end
  describe "add_cart" do
    let(:cart) { Cart.create_cart(user, company) }
    context "カートが一杯でない場合" do
      it "adds cart" do
        res = cart.add_cart(products.first.id, 1)
        expect(res).to eq I18n.t('activerecord.models.cart.add_cart')
      end
    end
    context "同一商品のサイズ違いの商品がカートに存在する場合" do
      it "can add cart" do
        res = cart.add_cart(products_has_size.first.id, 1, Size::M)
        expect(
          CartProduct.check_already_had?(
            cart,
            products_has_size.first.id,
            Size::M
          )
        ).to be_truthy

        res = cart.add_cart(products_has_size.first.id, 1, Size::S)
        expect(
          CartProduct.check_already_had?(
            cart,
            products_has_size.first.id,
            Size::S
          )
        ).to be_truthy
        expect(res).to eq I18n.t('activerecord.models.cart.add_cart')

        res = cart.add_cart(products_has_size.first.id, 5, Size::M)
        q = CartProduct.product_quantity(
          cart,
          products_has_size.first.id,
          Size::M
        )
        expect(res).to eq I18n.t('activerecord.models.cart.change_quantity')
        expect(q).to eq 5

      end
    end
    context "カートにテイクアウト商品と一般商品が混在する場合" do
      it "does not add product to cart" do
        res = cart.add_cart(products.first.id, 1)
        res = cart.add_cart(products_for_take_out.first.id, 1)
        expect(res).to eq I18n.t('activerecord.models.cart.mix_in_error_with_take_over')
      end
    end
    context "カートに10件以上の商品が存在する場合" do
      it "can not adds cart" do
        res = ""
        11.times do | i |
          res = cart.add_cart(products[i].id, 1)
        end
        expect(res).to eq 'カートには最大' + Cart::MAX_ITEMS.to_s + '個の商品しか入りません'

      end
    end
  end
end
