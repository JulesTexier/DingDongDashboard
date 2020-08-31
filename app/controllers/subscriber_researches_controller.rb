class SubscriberResearchesController < ApplicationController
  before_action :load_subscriber_research_wizard, except: %i(validate_step)

  def validate_step
    current_step = params[:current_step]

    @subscriber_research_wizard = wizard_subscriber_research_for_step(current_step)
    @subscriber_research_wizard.subscriber_research.attributes = subscriber_research_wizard_params
    session[:subscriber_research_attributes] = @subscriber_research_wizard.subscriber_research.attributes

    if @subscriber_research_wizard.valid?
      next_step = wizard_subscriber_research_next_step(current_step)
      create and return unless next_step

      redirect_to action: next_step
    else
      render current_step
    end
  end

  def step2
    byebug
  end

  def create
    @subscriber_research_wizard.subscriber_research.subscriber_id = params[:subscriber_id]
    if @subscriber_research_wizard.subscriber_research.save
      session[:subscriber_research_attributes] = nil
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
    params.require(:subscriber_research_wizard).permit(:agglomeration, :min_surface, :min_price)
  end

  class InvalidStep < StandardError; end 
end
