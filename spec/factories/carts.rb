FactoryBot.define do
  factory :cart do
    line_user
    company
    sequence(:cart_hash) { |n| "cart_hash#{n}" }
  end
end
