class ReserveDetail < ApplicationRecord
  belongs_to :line_user
  belongs_to :order
  belongs_to :cart

  scope :excluded_one_month_before, -> { where('take_over_date > ?', Time.current.ago(1.month)) }

  def self.upsert(cart, order, reserve_times)
    reserve_detail = self.find_by(cart: cart, line_user: cart.line_user)
    if reserve_detail.nil?
      ReserveDetail.create( \
        cart: cart, \
        line_user: cart.line_user, \
        order: order, \
        take_over_date: reserve_times[0], \
        take_over_time_from: reserve_times[1], \
        take_over_time_to: reserve_times[2], \
      )
    else
      reserve_detail.update(
        order: order, \
        take_over_date: reserve_times[0], \
        take_over_time_from: reserve_times[1], \
        take_over_time_to: reserve_times[2], \
      )
    end
  end
end
