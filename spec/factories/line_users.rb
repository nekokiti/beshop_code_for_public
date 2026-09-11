FactoryBot.define do
  factory :line_user do
    sequence(:line_id) { |n| "line_id#{n}" }
    email { Faker::Internet.email }
    zip { Faker::Address.zip }
    tel { Faker::PhoneNumber.cell_phone_in_e164 }
    address_country { Faker::Address.country }
    address_state { Faker::Address.state }
    address_city { Faker::Address.city }
    address_street { Faker::Address.street_name }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
  end
end
