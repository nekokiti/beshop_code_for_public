FactoryBot.define do
  factory :tag do
    sequence(:tag_name) { |n| "#{ Faker::Commerce.product_name }_#{n}" }
    image_path { Rack::Test::UploadedFile.new( Rails.root.join('spec/support/sample.jpg'), 'image/jpeg') }
  end
end
