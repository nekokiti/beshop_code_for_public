class TakeOverTime < ApplicationRecord
  belongs_to :cart
  belongs_to :order

  def self.create_take_over_time(time, cart)
    find_or_initialize_by(cart: cart) do |tt|
      tt.update_attributes!(
        take_over_time: time,
        cart: cart
      )
    end
  end

end
