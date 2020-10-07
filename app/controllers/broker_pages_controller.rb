class BrokerPagesController < ApplicationController

  HIDE_DAY_COUNT = 7 #Number of days a lead is hide to his broker
  DELAY_BROKER = 7
  
  def index
    @broker = Broker.find(params[:id])
    
    @subscribers = Subscriber.where(broker: @broker).where('created_at <  ?', Time.now - HIDE_DAY_COUNT.day).order('created_at DESC')
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
end
