require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Raven.configure do |config|
  config.dsn = 'https://2b4e8f64be144eaf957cb3d4a3d6dcf9:226139f096f44f0a948a149dda77270d@sentry.io/1494723'
  config.environments = %w[production]
end

module TalkSearch
  class Application < Rails::Application
    config.time_zone = 'Tokyo'
    config.paths.add 'lib', eager_load: true
    config.generators.template_engine = :slim
    config.i18n.default_locale = :ja
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.generators do |g|
      g.test_framework = "rspec"
    end
  end
end
