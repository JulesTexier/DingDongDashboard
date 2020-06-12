class UpdateAttributesSequence < ActiveRecord::Migration[6.0]
  def change
    remove_column :sequences, :trigger_ads
    remove_column :sequences, :sequence_type
    add_column :sequences, :marketing_link, :string
    remove_column :sequence_steps, :template
  end
end
