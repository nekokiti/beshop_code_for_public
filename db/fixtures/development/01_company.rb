Company.seed do |s|
  s.id = '1'
  s.email = ''
  s.password = ''
  s.company_name = ''
  s.unique_id = ''
  s.channel_access_token = ''
  s.channel_secret = ''
  s.confirmed_at = Date.today.to_time
  s.occupation_mst_id = 0
end
