module CouponMacros
  def create_coupon
    let(:coupon) do
      create(:product,
        name: Faker::Commerce.product_name,
        description: Faker::Lorem.characters(number: 20),
        url: Faker::Internet.url,
        image_path: Rack::Test::UploadedFile.new(
          Rails.root.join('spec/support/sample.jpg'), 'image/jpeg'
        ),
        quantity: Faker::Number.between(1, 100),
        price: Faker::Commerce.price,
        has_size: false,
        coupon_flg: true,
        recommend_flg: true)
    end
  end
end
