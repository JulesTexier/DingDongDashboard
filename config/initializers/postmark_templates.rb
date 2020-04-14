# Enables email previews via the Postmark API. The interceptor relies on
# the Postmark token being set for the current environment, which is
# normally defined in config/environments/application.rb or other
# environment-specific configs.
# 
# config.action_mailer.postmark_settings = { api_token: Rails.application.secrets.postmark_api_token }
#
if ActionMailer::Base.postmark_settings[:api_token].present?
  ActionMailer::Base.register_preview_interceptor(PostmarkRails::PreviewInterceptor)
end