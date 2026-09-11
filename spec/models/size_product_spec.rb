require 'rails_helper'

RSpec.describe SizeProduct, type: :model do
  let(:s_size) { Size.find(Size::S) }
  let(:m_size) { Size.find(Size::M) }
  let(:l_size) { Size.find(Size::L) }
  let!(:company) { create(:company) }
  let!(:products) {
    products = []
    3.times do
      product = create(:product, company: company, has_size: true, sizes: Size.all)
      products << product
    end
    products
  }

  describe 'product_size#check_quantity' do
    it 'checks quantity' do
      SizeProduct.releated_size(products.first, s_size)
                 .update_attribute(:quantity, 5)
      SizeProduct.releated_size(products.first, m_size)
                 .update_attribute(:quantity, 5)
      SizeProduct.releated_size(products.first, l_size)
                 .update_attribute(:quantity, 5)
      res = SizeProduct.check_quantity(products.first)
      expect(res.where(product_id: products.first.id).blank?).to be_falsey
      res = SizeProduct.check_quantity(products.third)
      expect(res.where(product_id: products.third.id).blank?).to be_truthy
    end
  end

  describe 'product_size#releated_size' do
    it 'gets available size of product' do
      product = products.first
      quantity = 10 
      s_size = Size.find(Size::S)
      size_product = SizeProduct.releated_size(product, s_size)
      size_product.update_attribute(:quantity, quantity)
      expect(SizeProduct.releated_size(product, s_size).quantity).to eq quantity
    end
  end

end
