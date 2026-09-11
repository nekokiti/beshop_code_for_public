FactoryBot.define do
  factory :reserve_time_b do
    days_after_from { 2 }
    days_after_to { 4 }
    from_time_1 { '10:00' }
    end_time_1 { '18:00' }
  end
end
