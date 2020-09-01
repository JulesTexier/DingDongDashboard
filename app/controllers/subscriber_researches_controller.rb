class SubscriberResearchesController < ApplicationController
  before_action :load_subscriber_research_wizard, except: %i(validate_step)

  def validate_step
    current_step = params[:current_step]
    @subscriber_research_wizard = wizard_subscriber_research_for_step(current_step)
    @subscriber_research_wizard.subscriber_research.attributes = subscriber_research_wizard_params
    session[:subscriber_research_attributes] = @subscriber_research_wizard.subscriber_research.attributes
    
    ## Need to keep this params for research_area. Stored it in session.
    session[:areas] = params[:areas] unless params[:areas].nil?

    if @subscriber_research_wizard.valid?
      next_step = wizard_subscriber_research_next_step(current_step)
      create and return unless next_step

      redirect_to action: next_step
    else
      render current_step
    end
  end

  def step1
    @agglos_infos = Area.get_agglo_infos
  end

  def step2
    session[:areas] = [] if session[:areas].nil?
    default_areas = session[:areas].flatten.map! {|id| id.to_i }
    @master_areas = Area.get_selected_agglo_area(@subscriber_research_wizard.agglomeration, default_areas)
  end

  def step3
    if session[:areas].empty?
      flash[:error] = "Veuillez sélectionner une zone de recherche."
      redirect_to step2_subscriber_subscriber_researches_path
    end
  end

  def create
    @subscriber_research_wizard.subscriber_research.subscriber_id = params[:subscriber_id]
    if @subscriber_research_wizard.subscriber_research.save
      @subscriber_research_wizard.subscriber_research.update_research_areas(session[:areas])
      session[:subscriber_research_attributes] = nil
      session[:areas] = nil
      redirect_to root_path, notice: 'Research succesfully created!'
    else
      redirect_to({ action: Wizard::SubscriberResearch::STEPS.first }, alert: 'There were a problem when creating the research.')
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
    "Wizard::SubscriberResearch::#{step.camelize}".constantize.new(session[:subscriber_research_attributes])
  end

  def subscriber_research_wizard_params
    params.require(:subscriber_research_wizard).permit(:agglomeration, :min_floor, :has_elevator, :min_elevator_floor, :min_surface, :min_rooms_number, :max_price, :min_price, :max_sqm_price, :balcony, :terrace, :garden, :new_construction, :last_floor, :home_type, :appartement_type, :email_flux, :messenger_flux)
  end

  class InvalidStep < StandardError; end
end
