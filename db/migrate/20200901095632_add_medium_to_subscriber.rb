class AddMediumToSubscriber < ActiveRecord::Migration[6.0]
  def change
    remove_column :researches, :messenger_flux, :boolean
    remove_column :researches, :email_flux, :boolean
    add_column :subscribers, :messenger_flux, :boolean
    add_column :subscribers, :email_flux, :boolean
  end
end
