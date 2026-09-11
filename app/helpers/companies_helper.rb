module CompaniesHelper
  def webhook_url(unique_key)
    "#{root_url(only_path: false).chop!}:443/callback?company=#{(unique_key)}"
  end
end
