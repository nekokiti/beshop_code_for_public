require 'rails_helper'

RSpec.describe BusinessHour, type: :model do
  describe "BusinessHour#is_shop_open?" do
    create_business_hour
    it "check open time" do
      if Time.current > open_time && Time.current < close_time
        expect(BusinessHour.is_shop_open?(company: company)).to be_truthy
      else
        expect(BusinessHour.is_shop_open?(company: company)).to be_falsey
      end
    end
  end
end
