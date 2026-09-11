require 'rails_helper'
require 'sidekiq/testing'
RSpec.describe ImportProductByCsvWorker, type: :worker do
  let(:company) { create(:company) }
  let!(:tags) do
    tags = []
      tags << create(:tag,
                     tag_name: '猫',
                     company: company,
                     image_path: Rack::Test::UploadedFile.new(
                       Rails.root.join('spec/support/sample.jpg'), 'image/jpeg'
                     ))
      tags << create(:tag,
                     tag_name: '星',
                     company: company,
                     image_path: Rack::Test::UploadedFile.new(
                       Rails.root.join('spec/support/sample.jpg'), 'image/jpeg'
                     ))
    tags
  end
  let!(:products) do
    products = []
    3.times do
      products << create(:product,
                         jancode: Faker::Lorem.characters(number: 20),
                         company: company,
                         tags: tags,
                         disp_inventory_flg: true)
    end
    products
  end
  describe "ImportProductByCsvWorker" do
    it "insert product by csv" do
      Sidekiq::Testing.fake! do
        file = Rack::Test::UploadedFile.new(
          Rails.root.join('spec/support/products_sample.csv'), 'file/csv'
        )
        CSV.foreach(file.path, headers: true, skip_blanks: true, encoding: 'Shift_JIS:UTF-8').with_index(2) do |row, row_number|
        ImportProductByCsvWorker.new.perform(row.to_hash, row_number, company.id)
        expect(Product.last.name).to eq 'インポートするテストの商品だよ'
        expect(tags).to include Product.last.tags.first
        expect(tags).to include Product.last.tags.last
        end
      end
    end
  end
end
