require 'rails_helper'

RSpec.describe Product, :type => :model do
  create_sample_order

  describe 'product#is_include_otorioki_flg?' do
    it "includes otorioki_flg" do
      cart.products.each do |p|
        p.update!(otorioki_flg: true)
      end
      res = Product.include_otorioki_flg?(cart.products)
      expect(res).to be_truthy
    end
  end

  describe 'products#calc_price_with_tax' do
    context "normal tax" do
      it "products rate is 0.1" do
        p = products.first
        p.update!(price:100, reduction_tax: false)
        expect(p.calc_price_with_tax).to eq 110
      end
    end

    context "reduction_tax" do
      it "products rate is 0.08" do
        p = products.first
        p.update!(price:100, reduction_tax: true)
        expect(p.calc_price_with_tax).to eq 108
      end
    end

    context "tax_free" do
      it "products rate is 0" do
        p = products.first
        p.update!(price:100, tax_free_flg: true)
        expect(p.calc_price_with_tax).to eq 100
      end
    end
  end

  describe 'my_products' do
    let!(:product_2) { create(:product, company: company_2) }
    let(:company_2) { create(:company) }
    it "get's only specified company" do
      expect(Product.my_products(company_2).first.company).to eq company_2
    end
  end

  describe 'product#destroy' do
    it "also remove produt in cart(cart_products)" do
      expect(cart.products).to include products.first
      products.first.destroy
      expect(cart.products).not_to include products.first
    end
  end

  describe 'product#check_inventory' do
    context "商品の在庫が一つ以上存在する場合" do
      it "returns true" do
        products.first.update(quantity: 50)
        products_has_size.each do |product|
          size_product_s = SizeProduct.releated_size(product, Size.find(Size::S))
          size_product_s.update_attribute(:quantity, 5)
        end
        res = Product.check_inventory(cart)
        expect(res).to be_truthy
      end
    end
    context "商品に在庫切れが発生している場合" do
      it "checks product's inventory" do
        products.first.update(quantity: 0)
        products_has_size.each do |product|
          size_product_s = SizeProduct.releated_size(product, Size.find(Size::S))
          size_product_s.update_attribute(:quantity, 0)
        end
        res = Product.check_inventory(cart)
        expect(res).to be_falsey
      end
    end
  end

  describe 'has_inventory' do
    let!(:products_mix_with_no_quantity) {
      items = []
      5.times do |i|
        if i <= 0
          items.push(create(:product, company: company, quantity: 0))
        else
          items.push(create(:product, company: company))
        end
      end
      items
    }
    it "get's only specified company" do
      Product.my_products(company).has_inventory.each do | product |
        expect(product.quantity).to_not eq 0
      end
    end
  end

  describe 'get_recommend_products' do
    let!(:recommended_products) {
      products = []
      5.times do | i |
        products << create(:product, company: company, recommend_flg: true)
      end
      products
    }
    let!(:non_recommended_products) {
      products = []
      5.times do | i |
        products << create(:product, company: company)
      end
      products
    }
    it "gets products only reccomendition" do
      gotten_products = Product.get_recommend_products(0, company)
      expect(gotten_products.to_a).to eq recommended_products
      expect(gotten_products.to_a).not_to eq non_recommended_products
    end
  end

  describe 'get_products_by_tag' do
    let(:sample_tags) do
      tags = []
      5.times do
        tags << create(:tag, company: company)
      end
      tags
    end
    let!(:products_grouped_by_same_tags) {
      products = []
      5.times do | i |
        products << create(:product, company: company, tags: sample_tags)
      end
      5.times do | i |
        products << create(:product, company: company, tags: sample_tags, quantity: 0)
      end
      5.times do | i |
        product = create(:product,
                         company: company,
                         tags: sample_tags,
                         sizes: Size.all,
                         has_size: true)
        SizeProduct.releated_size(product, s_size)
                   .update_attribute(:quantity, 5)
        SizeProduct.releated_size(product, m_size)
                   .update_attribute(:quantity, 5)
        SizeProduct.releated_size(product, l_size)
                   .update_attribute(:quantity, 5)
        products << product
      end
      5.times do | i |
        product = create(:product,
                         company: company,
                         tags: sample_tags,
                         sizes: Size.all,
                         has_size: true)
        SizeProduct.releated_size(product, s_size)
                   .update_attribute(:quantity, 0)
        SizeProduct.releated_size(product, m_size)
                   .update_attribute(:quantity, 0)
        SizeProduct.releated_size(product, l_size)
                   .update_attribute(:quantity, 0)
        products << product
      end
      products
    }
    # [1 2 3 4 5] サイズ無し 在庫有り
    # [6 7 8 9 10] サイズ無し 在庫無し
    # [11 12 13 14 15] サイズ有り 在庫有り
    # [16 17 18 19 20] サイズ有り 在庫無し
    context 'タグに紐づく1番目の商品から最大10個の商品を取得' do
      it "gets products by tag and has inventory" do
        gotten_products = Product.get_products_by_tag(sample_tags.first,
                                                      0,
                                                      company)
        products_grouped_by_same_tags.slice!(15, 5)
        products_grouped_by_same_tags.slice!(5, 5)
        expect(gotten_products.to_a).to eq products_grouped_by_same_tags
      end
    end
    context 'タグに紐づく5番目の商品から最大10個の商品を取得' do
      it "gets products by tag and has inventory" do
        gotten_products = Product.get_products_by_tag(sample_tags.first,
                                                      products_grouped_by_same_tags[4],
                                                      company)
        products_grouped_by_same_tags.slice!(15, 5)
        products_grouped_by_same_tags.slice!(0, 10)
        expect(gotten_products.to_a).to eq products_grouped_by_same_tags
      end
    end
    context 'タグに紐づく商品がこれ以上ない' do
      it "gets products by tag and has inventory" do
        gotten_products = Product.get_products_by_tag(sample_tags.first,
                                                      products_grouped_by_same_tags[19],
                                                      company)
        expect(gotten_products).to be_falsey
      end
    end
  end

  describe 'decrement_inventory' do
    context "the last quantity is larger than 1" do
      it "decrement quantity of product" do
        products_old_quantity = []
        products.each do |product|
          products_old_quantity.push(product.quantity)
        end
        has_size_producs_old_quantity = []
        # サイズ有り商品はsample_orderでSサイズを一つずつ購入している
        products_has_size.each do |product|
          has_size_producs_old_quantity.push(
            SizeProduct.releated_size(product, s_size).quantity
          )
        end
        my_order = Order.create_order(cart, Order::LINE_PAY)
        Product.decrement_inventory(my_order.cart)
        products.each_with_index do |product, index|
          expect(product.reload.quantity).to eq(products_old_quantity[index] - 1)
        end

        products_has_size.each_with_index do |product, index|
          expect(SizeProduct.releated_size(product, s_size).quantity).to \
            eq(has_size_producs_old_quantity[index] - 1)
        end
      end
    end
    # context "the last quantity is larger than 1" do
    #  it "decrement quantity of product" do
    #    product.decrement_inventory(1000)
    #    expect(product.quantity).to eq 0
    #  end
    #end
  end
end
