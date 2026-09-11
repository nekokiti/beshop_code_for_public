# frozen_string_literal: true

class BusinessHour < ApplicationRecord
  belongs_to :company

  def self.is_shop_open?(company: target_company)
    return true if company.business_hour.nil?

    open = Time.zone.local(Time.current.year,
                    Time.current.month,
                    Time.current.day,
                    company.business_hour.open_time.hour,
                    company.business_hour.open_time.min)

    close = Time.zone.local(Time.current.year,
                    Time.current.month,
                    Time.current.day,
                    company.business_hour.close_time.hour,
                    company.business_hour.close_time.min)

    Time.current > open && Time.current < close
  end

end
