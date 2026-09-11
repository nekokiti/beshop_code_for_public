require 'rails_helper'

RSpec.describe "LineClient" do
  describe "get_user_profile" do
    it "gets user profile" do
      api_helper = ApiHelper.new(@proxy, LineClient::END_POINT)
      api_helper.request_uri = "/v2/bot/profile/U524dbb64838e00bb4c1dc87f570c7324"
      api_helper.headers = {
        "Authorization"=> "Bearer {}"
      }
      res = api_helper.get
      expect(res.body["displayName"]).to eq ""
    end
  end
end
