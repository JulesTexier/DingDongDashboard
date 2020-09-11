class BrokerMailer < ApplicationMailer  
  def new_lead(subscriber_id)
    @subscriber = Subscriber.find(subscriber_id)
    @broker = @subscriber.broker

    if !@subscriber.nil? && !@broker.nil? 
      subject = "[DING DONG] Nouveau contact"
      if Rails.env == "development"
        mail(from: "etienne@hellodingdong.com", to: "greg@hellodingdong.com", subject: subject)
      else 
        mail(from: "etienne@hellodingdong.com", to: @broker.email, subject: subject)
      end
    end
  end

  def weekly_update(broker_id)
    @subscribers = Subscriber.where(broker: broker_id)

    @dd_all = @subscribers.where(is_broker_affiliated: false).order('created_at DESC')
    @dd_week = @dd_all.where('created_at > ?', Time.now - 7.days )
    @own_all = @subscribers.where(is_broker_affiliated: true)
    @own_week = @own_all.where('created_at > ?', Time.now - 7.days )
    @dd_subs_data = []
    @dd_all.each do |sub|
      sub_hash = {}
      sub_hash[:name] = sub.get_fullname
      sub_hash[:created_at] = sub.created_at.strftime("%d/%m/%Y")
      sub_hash[:coords] = "Téléphone: #{sub.phone} \u000AEmail: #{sub.email}"
      sub_hash[:stop] = sub.is_active ? "OUI" : "NON"
      sub_hash[:criteria] = sub.get_criteria
      @dd_subs_data.push(sub_hash)
    end

    @own_subs_data = []
    @own_all.each do |sub|
      sub_hash = {}
      sub_hash[:name] = sub.get_fullname
      sub_hash[:created_at] = sub.created_at
      sub_hash[:coords] = "Téléphone: #{sub.phone} - email: #{sub.email}"
      sub_hash[:stop] = sub.is_active ? "NON" : "OUI"
      sub_hash[:criteria] = sub.get_criteria
      @own_subs_data.push(sub_hash)
    end
    byebug
    mail(from: "etienne@hellodingdong.com", to: "f.bonnand@gmail.com", subject: "DING DONG - Synthèse de la semaine")
  end
end
