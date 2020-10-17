class BrokerPagesController < ApplicationController
  before_action :authenticate_admin

  HIDE_DAY_COUNT = 7 #Number of days a lead is hide to his broker
  DELAY_BROKER = 7
  
  def index
    @broker = current_broker
    
    black_listed = []
    # @subscribers = @broker.subscribers.where('created_at <  ?', Time.now - HIDE_DAY_COUNT.day).order('created_at DESC').select{|s| (!s.has_stopped? || s.has_stopped? && (s.stopped_date - s.created_at) > 7.days) }
    @subscribers = @broker.subscribers.where('created_at <  ?', Time.now - HIDE_DAY_COUNT.day).order('created_at DESC').select{|s| (!s.has_stopped || s.has_stopped && (s.stopped_date_at - s.created_at) > 7.days) }
    @subscribers_week = @subscribers.select{|x| x.created_at >  Time.now - (7 + DELAY_BROKER).days }
    @subscribers_month = @subscribers.select{|x| x.created_at >  Time.now - (30 + DELAY_BROKER).days }
  end

  def checked_by_broker
    subscriber = Subscriber.find(params['checked_by_broker'])
    subscriber.update(checked_by_broker: !subscriber.checked_by_broker )
  end

  def admin
    @brokers = Broker.all.order(:agglomeration_id)
    @agglomerations = Agglomeration.all
    @broker_offset = 7
  end

  private
  def authenticate_admin
    redirect_to new_broker_session_path unless broker_signed_in?
  end

end
