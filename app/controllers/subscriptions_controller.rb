class SubscriptionsController < ApplicationController
  def index
    @subscriber = Subscriber.find(params[:subscriber_id])
    @is_client = @subscriber.is_subscriber_premium?
  end

  def new
    @publishable_key = ENV["STRIPE_PUBLISHABLE_KEY"]
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
    @checkout_session = Stripe::Checkout::Session.create(
      payment_method_types: ["card"],
      mode: "subscription",
      line_items: [{
        price: ENV["STRIPE_PRICE_ID"],
        quantity: 1,
      }],
      success_url: ENV["BASE_URL"] + "subscribers/" + params[:subscriber_id] + "/success?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: ENV["BASE_URL"] + "subscribers/" + params[:subscriber_id] + "/cancel",
    )
  end

  def success
    @subscriber = Subscriber.find(params[:subscriber_id])
    @subscriber.update(stripe_session_id: params[:session_id], is_blocked: false, is_active: true)
    @subscriber.statuses << Status.find_by(name: "has_paid_subscription")
    m = Manychat.new
    response = m.send_flow_sequence(@subscriber, "content20200609150547_506353")
    if response[0]
      json_response = { status: "SUCCESS", message: "The flow #{flow} has been sent to the subscriber #{@subscriber.id}", data: response[1] }
      status = 200
    else
      json_response = { status: "ERROR", message: "A error occur in manychat call", data: response[1] }
      status = 406
    end
  end

  def cancel
    @subscriber = Subscriber.find(params[:subscriber_id])
    @subscriber.statuses << Status.find_by(name: "has_cancelled_subscription")
  end
end
