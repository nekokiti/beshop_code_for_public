require 'json'
require 'rails_helper'

RSpec.describe "ApiHelper" do
  describe "help api access" do
    it "requests api by get" do
      end_point = "https://newsapi.org/"
      api_helper = ApiHelper.new(nil, end_point)
      api_helper.request_uri = "/v2/top-headlines"
    params = {
      country: "jp",
      category: "sports",
      apiKey: ''
    }
      api_helper.params = params
      res = api_helper.get
      expect(res).to be_truthy
    end
  end
end
