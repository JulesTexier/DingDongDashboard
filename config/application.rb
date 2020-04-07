require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GiantCat
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    # config.assets.initialize_on_precompile = false
    # config.assets.enabled = false

    config.action_mailer.delivery_method = :postmark
    config.action_mailer.postmark_settings = { api_token: '84616c63-f0f7-4cf7-8590-90e1dcc11302' }



    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.autoload_paths += [
      "#{Rails.root}/app/services/broadcasters",
      "#{Rails.root}/app/services/scrapers"
    ]
  end
end
