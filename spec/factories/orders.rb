FactoryBot.define do
  factory :order do
    line_user
    company
    cart
    verified { false }
    txn_id { Faker::Lorem.characters(20) }
    zip { Faker::Address.zip }
    address_country { Faker::Address.country }
    address_state { Faker::Address.state }
    address_city { Faker::Address.city }
    address_street { Faker::Address.street_name }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    tax { Faker::Commerce.price }
    mc_handling { Faker::Commerce.price }
    mc_shipping { Faker::Commerce.price }
  end
end
