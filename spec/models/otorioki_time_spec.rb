require 'rails_helper'

RSpec.describe OtoriokiTime, type: :model do
  create_sample_order
  describe "OtoriokiTime#search_longest_time" do
    it "gets the longest time for take over" do
      longest = 120
      cart.products.each do |p|
        p.update!(otorioki_flg: true)
        create(:otorioki_time, product: p, min_time: 30)
      end
      cart.products.first.otorioki_time.update!(min_time: longest)
      res = OtoriokiTime.search_longest_time(cart.products)
      expect(res).to eq longest
    end
  end
end
