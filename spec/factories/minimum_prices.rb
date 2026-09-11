FactoryBot.define do
  factory :minimum_price do
    price { Faker::Commerce.price }
  end
end
