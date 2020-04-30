class AddPhotoDescriptionToBroker < ActiveRecord::Migration[6.0]
  def change
    add_column :brokers, :profile_picture, :string, default: "https://hellodingdong.com/ressources/broker_pp_default.jpg"
    add_column :brokers, :description, :string, default: nil
  end
end
