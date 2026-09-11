FactoryBot.define do
  factory :size_product do
    size
    product
    quantity { Faker::Number.between(1, 100) }
  end
end
