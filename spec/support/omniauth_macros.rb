module OmniauthMacros
  def set_invalid_omniauth
    OmniAuth.config.mock_auth[:line] = :invalid_credentials
  end
  def line_mock
    OmniAuth.config.mock_auth[:line] = OmniAuth::AuthHash.new(
      {
        provider: 'line',
        uid: '12345',
        info: {
          name: 'mockuser',
          email: 'sample@test.com'
        },
        credentials: {
          token: 'hogefuga'
        }
      }
    )
    Rails.application.env_config["devise.mapping"] = Devise.mappings[:line_user] # If using Devise
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:line]
  end
end
