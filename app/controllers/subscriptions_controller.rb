class SubscriptionsController < ApplicationController
  def index
    puts params[:subscriber_id]
  end

  def new
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    @checkout_session = Stripe::Checkout::Session.create(
      payment_method_types: ["card"],
      mode: "subscription",
      line_items: [{
        price: "price_1GpwkGJ0w5Eyx13BMqa29pDs",
        quantity: 1,
      }],
      success_url: ENV["BASE_URL"] + "success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: ENV["BASE_URL"] + "cancel",
    )
  end

  def success
    puts params[:session_id]
    byebug
  end

  def cancel
  end
end
