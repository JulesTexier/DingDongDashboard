class BrokerPagesController < ApplicationController

  HIDE_DAY_COUNT = 7 #Number of days a lead is hide to his broker
  DELAY_BROKER = 7
  
  def index
    @broker = Broker.find(params[:id])
    
    black_listed = []
    # scoped_ids = SubscriberNote.where(content:"L'utilisateur a arrêté son alerte.").map{|s| s.subscriber_id}.each do |s|
    #   sub_note = SubscriberNote.where(subscriber_id: s).order('created_at DESC').first 
    #   black_listed.push(s) if sub_note.content == "L'utilisateur a arrêté son alerte." && (sub_note.created_at - sub_note.subscriber.created_at) < 1.week
    # end
    @subscribers = Subscriber.where(broker: @broker).where('created_at <  ?', Time.now - HIDE_DAY_COUNT.day).order('created_at DESC').select{|s| (!s.has_stopped? || s.has_stopped? && (s.stopped_date - s.created_at) > 7.days) }
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
