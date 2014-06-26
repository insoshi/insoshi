unless Rails.env == "production"
  Rails.configuration.stripe = {
    :publishable_key => "pk_test_X9TPxSlTGcaBwR3KasYLTm9T",
    :secret_key      => "sk_test_NQ5VD1mm7xgVkgoRPXCSYTHh",
    :mode => "test"
  }
else
  Rails.configuration.stripe = {
    :publishable_key => ENV['STRIPE_PUB_KEY'],
    :secret_key => ENV['STRIPE_SECRET_KEY'],
    :mode => "live"
  }
end

Stripe.api_key = Rails.configuration.stripe[:secret_key]
