class BrokerPagesController < ApplicationController

  HIDE_DAY_COUNT = 7 #Number of days a lead is hide to his broker
  
  def index
    @broker = Broker.find(params[:id])
    @delay_broker = 7
    @subscribers = Subscriber.where(broker: @broker).where('created_at <  ?', Time.now - HIDE_DAY_COUNT.day).order('created_at DESC')
  end
end
