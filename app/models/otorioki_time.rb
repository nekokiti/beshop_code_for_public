class OtoriokiTime < ApplicationRecord
  belongs_to :product

  def self.initial_time(cart)
    max = search_longest_time(cart.products)
    res = Time.zone.now + max * 60
    res.strftime("%Y-%m-%dT%H:%M")
  end

  def self.search_longest_time(products)
    longest_time = 0.to_i
    products.each do |p|
      time = p.otorioki_time.min_time
      longest_time = time if time > longest_time
    end
    longest_time
  end

end
