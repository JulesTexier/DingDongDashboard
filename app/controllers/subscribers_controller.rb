class SubscribersController < ApplicationController  

  
  # #########################
  #      BUSINESS LOGIC     #
  # #########################

  def professionals
    @subscriber = Subscriber.find(params[:subscriber_id])
    @notary = @subscriber.notary
    @broker = @subscriber.broker
    @contractor = @subscriber.contractor
  end
  
  def activation
    flow = "content20200716090652_490399"
    @subscriber = Subscriber.find(params[:subscriber_id])
    if !@subscriber.nil?
      @subscriber.update(is_blocked: false) 
      SubscriberStatus.create(subscriber: @subscriber, status: Status.find_by(name: "unblocked"))
      Manychat.new.send_flow_sequence(@subscriber, flow)
    end
  end

  def confirm_email
    subscriber = Subscriber.find_by_confirm_token(params[:token])
    if subscriber
      subscriber.validate_email
      subscriber.save(validate: true)
      SubscriberMailer.welcome_email(subscriber).deliver_now
      redirect_to subscriber_email_confirmed_path(subscriber)
    else
      flash[:error] = "Désolé, l'utilisateur n'existe pas"
      redirect_to url_not_found_path
    end
  end

  def email_validation
    @subscriber = Subscriber.find(params[:subscriber_id])
  end

  def email_confirmed
    subscriber = Subscriber.find(params[:subscriber_id])
    redirect_to root_path if subscriber.messenger_flux || !subscriber 
  end

  def broker_onboarding
    session[:broker_id] = params[:broker_id]
    redirect_to step1_subscriber_researches_path
  end

  def contact_courtier
    @subscriber = Subscriber.find(params[:subscriber_id])
    @question_categories = ["Evaluer ma capacité d'emprunt", "Informations sur les taux", "Parler à un courtier", "Point sur ma situation" ,"Autre"]
    SubscriberNote.create(subscriber: @subscriber, content: "S'est rendu sur la page 'mon financement'")
    AdminMailer.subscriber_funding_question(@subscriber.id).deliver_now
  end

  def contact_courtier_submit
    subscriber = Subscriber.find(params[:subscriber_id])
    question_category = params["question_category"]
    question_content = params["question_content"]
    SubscriberNote.create(subscriber: subscriber, content: "A posé la question suivante: '#{question_content}'")
    redirect_to subscriber_mon_financement_confirmation_path
  end

  def contact_courtier_submitted
  end


  private

  def subscriber_params
    params.require(:subscriber).permit(:firstname, :lastname, :email, :phone, :has_messenger, :facebook_id, :max_price, :min_surface, :min_rooms_number, :min_elevator_floor, :min_floor, :project_type, :additional_question, :specific_criteria, :broker_id, :status, :initial_areas, :terrace, :garden, :balcony, :new_construction, :last_floor, :min_price, :max_sqm_price)
  end
end

