FactoryBot.define do
  factory :shipping do
    shipping_fee { Faker::Commerce.price }
    extra_fee { Faker::Commerce.price }
    company
  end
end
