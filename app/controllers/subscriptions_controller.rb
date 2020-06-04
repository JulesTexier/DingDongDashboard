class SubscriptionsController < ApplicationController
  helper_method :is_subscriber_client

  def index
    @subscriber = Subscriber.find(params[:subscriber_id])
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
    @subscriber = Subscriber.find(params[:subscriber_id])
    @subscriber.update(stripe_session_id: params[:session_id], is_blocked: false)
    @subscriber.statuses << Status.find_by(name: "has_paid_subscription")
  end

  def cancel
    @subscriber = Subscriber.find(params[:subscriber_id])
    @subscriber.statuses << Status.find_by(name: "has_cancelled_subscription")
  end

  def end_subscription
    @subscriber = Subscriber.find(params[:subscriber_id])
    session = Stripe::Checkout::Session.retrieve(@subscriber.stripe_session_id)
    Stripe::Subscription.delete(session.subscription) unless @subscription_id.nil?
    @subscriber.statuses << Status.find_by(name: "has_ended_subscription")
  end

  private

  def is_subscriber_client
    status_ids = Status.where(name: ["has_paid_subscription", "has_cancelled_subscription", "has_ended_subscription"]).pluck(:id)
    status = Subscriber.find(params[:subscriber_id])
      .subscriber_statuses
      .where(status_id: status_ids)
      .last
      .status
    status.name == "has_paid_subscription" ? true : false
  end
end
