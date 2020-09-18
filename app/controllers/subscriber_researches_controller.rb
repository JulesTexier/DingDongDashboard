class SubscriberResearchesController < ApplicationController
  before_action :load_subscriber_research_wizard, except: [:edit, :update, :validate_step, :stop, :activate]

  def validate_step
    current_step = params[:current_step]
    @subscriber_research_wizard = wizard_subscriber_research_for_step(current_step)
    @subscriber_research_wizard.subscriber_research.attributes = subscriber_research_wizard_params unless current_step == "step3"
    @subscriber_research_wizard.attributes = subscriber_wizard_params if current_step == "step3"
    session[:subscriber_research_attributes] = @subscriber_research_wizard.subscriber_research.attributes
    session[:subscriber_attributes] = @subscriber_research_wizard.subscriber.attributes
    ## Need to keep this params for research_area. Stored it in session.
    session[:areas] = params[:areas] unless params[:areas].nil?
    if @subscriber_research_wizard.valid?
      next_step = wizard_subscriber_research_next_step(current_step)
      create and return unless next_step

      redirect_to action: next_step
    else
      flash.now[:danger] = "Une erreur s'est produite, veuillez réessayer."
      render current_step
    end
  end

  def step1
    session[:areas] = [] #Reboot areas in case user changes agglomeration
    @agglomerations_infos = Agglomeration.all
  end

  def step2
    session[:areas] = [] if session[:areas].nil?
    @master_areas = Area.selected_area_onboarding(@subscriber_research_wizard.agglomeration, session[:areas])
  end
  
  def step3
    if session[:areas].empty?
      flash.now[:danger] = "Veuillez sélectionner une zone de recherche."
      redirect_to step2_subscriber_researches_path
    end
    # @average_results = @subscriber_research_wizard.subscriber_research.average_results_estimation(15)
  end

  def create
    subscriber_lead = Subscriber.find_by(email: @subscriber_research_wizard.subscriber.email, status:"new_lead")
    if subscriber_lead.nil?
      save_subscriber = @subscriber_research_wizard.subscriber.save(context: :onboarding)
      subscriber =  @subscriber_research_wizard.subscriber
    else
      save_subscriber =  subscriber_lead.update_attributes(firstname:  @subscriber_research_wizard.subscriber.firstname, lastname:  @subscriber_research_wizard.subscriber.lastname, phone:  @subscriber_research_wizard.subscriber.phone, messenger_flux:  @subscriber_research_wizard.subscriber.messenger_flux, email_flux:  @subscriber_research_wizard.subscriber.email_flux, status:"")
      subscriber = subscriber_lead
    end
    # save_subscriber = subscriber_lead.nil? ? @subscriber_research_wizard.subscriber.save(context: :onboarding) : subscriber_lead.update_attributes(firstname:  @subscriber_research_wizard.subscriber.firstname, lastname:  @subscriber_research_wizard.subscriber.lastname, phone:  @subscriber_research_wizard.subscriber.phone, messenger_flux:  @subscriber_research_wizard.subscriber.messenger_flux, email_flux:  @subscriber_research_wizard.subscriber.email_flux, status:"")
    if save_subscriber
      subscriber.update(broker:Broker.find(session[:broker_id]), is_broker_affiliated: true) unless session[:broker_id].nil?
      @subscriber_research_wizard.subscriber_research.subscriber_id = subscriber.id
      if @subscriber_research_wizard.subscriber_research.save
        subscriber.handle_onboarding
        @subscriber_research_wizard.subscriber_research.update_research_areas(session[:areas])
        session[:subscriber_research_attributes] = nil
        session[:subscriber_attributes] = nil
        session[:areas] = nil
        redirect_to subscriber_professionals_path(subscriber.id), success: 'Votre alerte a été correctement créée!'
      else
        flash[:danger] = "Une erreur s'est produite, veuillez réessayer."
        redirect_to({ action: Wizard::SubscriberResearch::STEPS.second })
      end
    else 
      flash.now[:danger] = "Une erreur s'est produite, veuillez réessayer."
      render params[:current_step]
    end
  end

  def edit 
    @subscriber = Subscriber.find(params[:subscriber_id])
    @research = @subscriber.research
    subscriber_areas_id = @research.areas.pluck(:id)
    @master_areas = Area.selected_area_edit(@research.agglomeration, subscriber_areas_id)
  end

  def update
    @subscriber = Subscriber.find(params[:subscriber_id])
    @research = @subscriber.research
    areas_ids = []
    areas_ids += params[:areas] unless params[:areas].nil?
    if @research.update(research_params) && !areas_ids.empty?
      @research.update_research_areas(areas_ids)
      flash[:success] = "Les critères sont enregistrés ! Fermez cette fenêtre pour continuer."
    else
      flash[:danger] = "Sélectionnez des arrondissements..."
    end
    # // Send flow to subscriber
    if @subscriber.messenger_flux
      flow = "content20200914131931_703524"
      Manychat.new.send_flow_sequence(@subscriber, flow) unless Rails.env.development?
    end
    redirect_to subscriber_research_edit_path(@subscriber)
  end


  def stop
    begin
      @confirmation = false
      @subscriber = Subscriber.find(params[:subscriber_id])
      if @subscriber.update(is_active: false)
        @confirmation = true
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path
    end
  end

  def activate 
    begin
      @confirmation = false
      @subscriber = Subscriber.find(params[:subscriber_id])
      if @subscriber.update(is_active: true)
        @confirmation = true
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path
    end
  end

  private

  def load_subscriber_research_wizard
    @subscriber_research_wizard = wizard_subscriber_research_for_step(action_name)
  end

  def wizard_subscriber_research_next_step(step)
    Wizard::SubscriberResearch::STEPS[Wizard::SubscriberResearch::STEPS.index(step) + 1]
  end

  def wizard_subscriber_research_for_step(step)
    raise InvalidStep unless step.in?(Wizard::SubscriberResearch::STEPS)
    "Wizard::SubscriberResearch::#{step.camelize}".constantize.new(session[:subscriber_research_attributes], session[:subscriber_attributes])
  end

  def subscriber_research_wizard_params
    params.require(:subscriber_research_wizard).permit(:agglomeration, :min_floor, :has_elevator, :min_elevator_floor, :min_surface, :min_rooms_number, :max_price, :min_price, :max_sqm_price, :balcony, :terrace, :garden, :new_construction, :last_floor, :home_type, :appartement_type)
  end

  def subscriber_wizard_params
    params.require(:subscriber_wizard).permit(:subscriber_firstname, :subscriber_lastname, :subscriber_email, :subscriber_phone, :subscriber_messenger_flux, :subscriber_email_flux)
  end

  def research_params
    params.require(:research).permit(:agglomeration, :min_floor, :has_elevator, :min_elevator_floor, :min_surface, :min_rooms_number, :max_price, :min_price, :max_sqm_price, :balcony, :terrace, :garden, :new_construction, :last_floor, :home_type, :appartement_type)
  end

  class InvalidStep < StandardError; end
end
