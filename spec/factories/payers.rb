FactoryBot.define do
  factory :payer do
    zip { Faker::Address.zip }
    address_country { Faker::Address.country }
    address_state { Faker::Address.state }
    address_street { Faker::Address.street_name }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    sequence(:payer_id) { |n| "payer_id_#{n}" }
    line_user
  end
end
