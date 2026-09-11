class OmniauthCallbacksController < ApplicationController
  require "securerandom"
  before_action :set_company
  before_action :set_redirect_uri
  TEST_LINE_USER_ID = "test_line_user_id".freeze

  def auth_require
    auth_url = 'https://access.line.me/oauth2/v2.1/authorize?' \
    "response_type=code" \
    "&client_id=#{@company.line_auth_info.channel_id}" \
    "&redirect_uri=#{CGI.escape(@redirect_uri)}" \
    "&state=#{SecureRandom.uuid}" \
    "&scope=profile"
    if Rails.env.test?
      head :no_content
    else
      redirect_to auth_url
    end
  end

  def get_auth_code
    begin
      api_helper = ApiHelper.new(nil, LineClient::END_POINT)
      api_helper.request_uri = "/oauth2/v2.1/token"
      api_helper.headers = {
        "Content-type" => 'application/x-www-form-urlencoded'
      }
      body =
        "grant_type=authorization_code&" \
        "code=#{params['code']}&" \
        "redirect_uri=#{@redirect_uri}&" \
        "client_id=#{@company.line_auth_info.channel_id}&" \
        "client_secret=#{@company.line_auth_info.decrypt_keys}"
      api_helper.params = body
      if !Rails.env.test?
        res = api_helper.post
      else
        hash = { "body": { "access_token" => "test_sample_token" } }
        res = Struct.new(*(hash.keys)).new(*(hash.values))
      end
      create_line_user(res.body['access_token'])
    rescue => e
      Rails.logger.error e.message
      Raven.capture_exception(e)
      render_500
    end
    redirect_to controller: 'public', action: 'auth_finish'
  end

  private
  def set_redirect_uri
    @redirect_uri = omniauth_get_auth_code_url("#{params['company_id']}")
  end
  def set_company
    @company = Company.get_company_with_uuid(params['company_id'])
  end
  def create_line_user(access_token)
    api_helper = ApiHelper.new(nil, LineClient::END_POINT)
    api_helper.request_uri = "/v2/profile"
    api_helper.headers = {
      "Authorization"=> "Bearer #{access_token}",
    }
    if !Rails.env.test?
      res = api_helper.get
    else
      hash = { "body": { "userId" => TEST_LINE_USER_ID } }
      res = Struct.new(*(hash.keys)).new(*(hash.values))
    end
    LineUser.create_line_user(res.body["userId"], @company)
  end

end
