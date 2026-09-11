FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.characters(number: 20) }
    url { Faker::Internet.url }
    image_path { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/sample.jpg'), 'image/jpeg') }
    movie_path { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/SampleVideo_360x240_1mb.mp4'), 'video/mp4') }
    quantity { Faker::Number.between(from: 1, to: 100) }
    price { Faker::Commerce.price }
  end
end
