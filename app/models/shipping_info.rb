class ShippingInfo < ApplicationRecord
  belongs_to :order
  belongs_to :shipping_company
end
