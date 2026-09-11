class Size < ApplicationRecord
  has_many :size_products
  has_many :products, through: :size_products
  # ↓いるか？
  has_many :cart_products
  has_many :order_products

  NO_SIZE = '0'.freeze
  XS = 1
  S = 2
  M = 3
  L = 4
  XL = 5

end
