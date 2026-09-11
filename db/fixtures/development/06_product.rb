Product.seed do |s|
  s.id = '1'
  s.name = 'test'
  s.url = 'http://www.byte-road.com'
  s.description = 'sample description'
  s.price = '450'
  s.quantity = '5'
  s.company = Company.find(1)
  s.recommend_flg = true
end
