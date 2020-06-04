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
      success_url: ENV["BASE_URL"] + "subscribers/" + params[:subscriber_id] + "/success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: ENV["BASE_URL"] + "subscribers/" + params[:subscriber_id] + "/cancel",
    )
  end

  def success
    session = Stripe::Checkout::Session.retrieve(params[:session_id])
    Subscriber.find(params[:subscriber_id]).update(stripe_customer_id: session.customer, is_blocked: false)
  end

  def cancel
  end
end
