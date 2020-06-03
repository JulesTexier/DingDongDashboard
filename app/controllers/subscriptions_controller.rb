class SubscriptionsController < ApplicationController
  def new
    Stripe.api_key = "sk_test_Ehoe6vR3ZldEruEt0TW2FPnJ00wLKZ4V3s"

    session = Stripe::Checkout::Session.create(
      payment_method_types: ["card"],
      line_items: [{
        price: "price_1GpwkGJ0w5Eyx13BMqa29pDs",
        quantity: 1,
      }],
      mode: "payment",
      success_url: "https://example.com/success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: "https://example.com/cancel",
    )

    byebug
  end
end
