require 'rails_helper'
require 'json'

RSpec.describe ProductsController, type: :request do
  login_company
  let(:tags) do
    tags = []
    5.times do
      tags << create(:tag, company: company)
    end
    tags
  end
  let!(:products) do
    products = []
    2.times do
      products << create(:product, company: company)
    end
    products
  end

  describe 'products' do
    before do
      get products_url
    end
    it "get #index" do
      expect(response).to be_success
    end
    it "gets products related sign in compnay" do
      products.each do | product |
        expect(response.body).to include product.name
      end
    end
  end

  describe "GET #show" do
    before do
      get product_url products.first.to_param
    end
    it "returns a success response" do
      expect(response).to be_success
    end
    it "assigns a proper product" do
      expect(response.body).to include products.first.name
    end
  end

  describe "GET #new" do
    before do
      get new_product_url, params: {}
    end
    it "returns a success response" do
      expect(response).to be_success
    end
  end

  describe "GET #edit" do
    before do
      get edit_product_url products.first.to_param
    end
    it "returns a success response" do
      expect(response).to be_success
    end
    it "assigns a product" do
      expect(response.body).to include products.first.name
    end
  end

  describe "GET #csv_export" do
    it "returns a success response" do
      get csv_export_products_url
      expect(response).to be_success
    end
  end

  describe "POST #csv_import" do
    it "creates a new Product by csv" do
      file = Rack::Test::UploadedFile.new(
        Rails.root.join('spec/support/products_sample.csv'), 'file/csv'
      )
      post csv_import_products_url, params: {file: file}
      expect(response).to redirect_to products_url
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_attributes) do
        {
          name: Faker::Commerce.product_name,
          description: Faker::Lorem.characters(number: 20),
          url: Faker::Internet.url,
          image_path: Rack::Test::UploadedFile.new(
            Rails.root.join('spec/support/sample.jpg'), 'image/jpeg'
          ),
          quantity: Faker::Number.between(from: 1, to: 100),
          price: Faker::Commerce.price,
          has_size: true,
          coupon_flg: false,
          no_extra_fee: false,
          recommend_flg: true,
          otorioki_flg: true,
          tag_ids: [tags.first.id, tags.second.id],
          otorioki_time_attributes: { min_time: 30 },
          size_products_attributes: [
            { quantity: 5, size_id: Size::XS },
            { quantity: 5, size_id: Size::S },
            { quantity: 5, size_id: Size::M },
            { quantity: 5, size_id: Size::L },
            { quantity: 5, size_id: Size::XL }
          ]
        }
      end
      it 'creates a new Product' do
        expect do
          post products_url, params: { product: valid_attributes }
        end.to change(Product, :count).by(1)
        expect(Product.last.recommend_flg).to be_truthy
        expect(Product.last.otorioki_flg).to be_truthy
        expect(Product.last.otorioki_time.min_time).to eq 30
        expect(Product.last.tags).to include tags.first, tags.second
        expect(Product.last.size_products.first.size_id).to eq Size::XS
        expect(Product.last.size_products.first.quantity).to eq 5
      end

      it 'redirects to the created product' do
        post products_url, params: { product: valid_attributes }
        expect(response).to redirect_to(product_url(Product.last))
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) do
        {
          url: Faker::Internet.url,
          image_path: Faker::Company.logo,
          quantity: Faker::Number.between(1, 100),
        }
      end
      it "doesn't create product" do
        expect {
          post products_url, params: {product: invalid_attributes}
        }.to_not change(Product, :count)
      end
    end

    context 'creates coupon' do
      let(:coupon_attributes) do
        {
          name: Faker::Commerce.product_name,
          description: Faker::Lorem.characters(number: 20),
          url: Faker::Internet.url,
          image_path: Rack::Test::UploadedFile.new(
            Rails.root.join('spec/support/sample.jpg'), 'image/jpeg'
          ),
          quantity: Faker::Number.between(from: 1, to: 100),
          price: Faker::Commerce.price,
          has_size: false,
          coupon_flg: true,
          recommend_flg: true,
          tag_ids: [tags.first.id, tags.second.id]
        }
      end
      it 'creates a new Coupon' do
        expect do
          post products_url, params: { product: coupon_attributes }
        end.to change(Product, :count).by(1)
        expect(Product.last.coupon_flg).to be_truthy
        expect(Product.last.no_extra_fee).to be_truthy
      end
    end
  end

  describe "PUT #update" do
    let(:new_attributes) do {
      name: Faker::Commerce.product_name + "_new"
    }
    end

    it "is success to request" do
      put product_url products.first, params: { product: new_attributes }
      expect(response.status).to eq 302
    end

    it "redirect to the updated product" do
      put product_url products.first, params: { product: new_attributes }
      expect(response).to redirect_to(products.first)
    end

    it "updates the requested product" do
      old_name = products.first.name
      new_name = new_attributes[:name]
      expect do
        put product_url products.first, params: { product: new_attributes }
      end.to change { Product.find(products.first.id).name }.from(old_name).to(new_name)
      expect(flash[:notice]).to eq 'Product was successfully updated.'
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested product" do
      expect {
        delete product_url products.first
      }.to change(Product, :count).by(-1)
    end

    it "redirects to the tags list" do
      delete product_url products.first
      expect(response).to redirect_to(products_url)
    end
  end

end
