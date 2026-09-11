Shipping.seed do |s|
  s.id = '1'
  s.shipping_fee = 10
  s.extra_fee = 30
  s.company = Company.find(1)
end
