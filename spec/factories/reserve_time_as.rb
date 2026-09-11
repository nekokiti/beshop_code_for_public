FactoryBot.define do
  factory :reserve_time_a do
    start_date { '2020-09-01' }
    end_date { '2020-09-05' }
    from_time_1 { '09:00' }
    end_time_1 { '22:00' }
  end
end
