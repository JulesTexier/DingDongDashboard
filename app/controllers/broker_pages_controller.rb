class BrokerPagesController < ApplicationController

  HIDE_DAY_COUNT = 7 #Number of days a lead is hide to his broker
  
  def index
    @broker = Broker.find(params[:id])
    @delay_broker = 7
    @subscribers = Subscriber.where(broker: @broker).where('created_at <  ?', Time.now - HIDE_DAY_COUNT.day).order('created_at DESC')
  end

  def checked_by_broker
    subscriber = Subscriber.find(params['checked_by_broker'])
    subscriber.update(checked_by_broker: !subscriber.checked_by_broker )
  end
end
