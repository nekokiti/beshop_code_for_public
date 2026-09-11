FactoryBot.define do
  factory :company do
    company_name { Faker::Company.name }
    email { Faker::Internet.email }
    channel_secret { Faker::Lorem.characters(8) }
    channel_access_token { Faker::Lorem.characters(50) }
    unique_id { "uuid" }
    password { "password" }
    password_confirmation { "password" }
    confirmed_at { Date.today }
    occupation_mst_id { OccupationMst::DEFAULT }
    after(:build) do |company|
      encrypt_key = company.encrypt_channel_secret(company.channel_secret)
      company.update(channel_secret: encrypt_key)
    end
  end
end
