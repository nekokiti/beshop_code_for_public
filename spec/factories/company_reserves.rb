FactoryBot.define do
  factory :company_reserve, class: 'CompanyReserve' do
    company
    after(:build) do |company_reserve|
      company_reserve.reserve_time_as << FactoryBot.build(:reserve_time_a)
      company_reserve.reserve_time_b = FactoryBot.build(:reserve_time_b)
    end
  end
end
