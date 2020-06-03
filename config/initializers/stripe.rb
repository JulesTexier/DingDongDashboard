Rails.configuration.stripe = {
  :publishable_key => "pk_test_95wWUVWPgrzNeyu7Ju43Lhht00lLYPBsB0",
  :secret_key => "sk_test_Ehoe6vR3ZldEruEt0TW2FPnJ00wLKZ4V3s",
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
