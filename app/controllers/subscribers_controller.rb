class SubscribersController < ApplicationController

  def show
    @subscriber = Subscriber.find(params[:id])
  end

  def edit
    @subscriber = Subscriber.find(params[:id])
  end

  def update
    @subscriber = Subscriber.find(params[:id])
    if @subscriber.update(subscriber_params)
      flash[:success] = "Les informations ont été mises à jour"
    else 
      flash[:danger] = []
      @user.errors.full_messages.each do |message|
        flash[:danger] << message
      end
      flash[:danger] = flash[:danger].join(" & ")
    end
    redirect_to edit_subscriber_path
  end

  private

  def subscriber_params
    params.require(:subscriber).permit(:firstname, :lastname, :email, :phone, :facebook_id, :max_price, :min_surface, :min_rooms_number, :min_elevator_floor, :min_floor)
  end 

end
