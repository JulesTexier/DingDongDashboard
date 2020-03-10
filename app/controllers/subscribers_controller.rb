class SubscribersController < ApplicationController

  def show
    @subscriber = Subscriber.find(params[:id])
  end

  def edit
    @subscriber = Subscriber.find(params[:id])
    @areas = Area.all
  end

  def update
    @subscriber = Subscriber.find(params[:id])
    SelectedArea.where(subscriber: @subscriber).destroy_all
    if @subscriber.update(subscriber_params) && !params[:selected_area].nil?
      params[:selected_area].each do |area_id|
        SelectedArea.create(subscriber:@subscriber, area_id:area_id)
      end
      flash[:success] = "Les critères sont enregistrés ! Ferme cette fenêtre pour continuer."
    else 
      flash[:danger] = "Sélectionne des arrondissements..."
      # @subscriber.errors.full_messages.each do |message|
      #   flash[:danger] << message
      # end
      # flash[:danger] = flash[:danger].join(" & ")
    end
    redirect_to edit_subscriber_path
  end

  private

  def subscriber_params
    params.require(:subscriber).permit(:firstname, :lastname, :email, :phone, :facebook_id, :max_price, :min_surface, :min_rooms_number, :min_elevator_floor, :min_floor)
  end 

end
