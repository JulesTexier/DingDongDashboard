class RenameColumnsSequenceAndSequenceStep < ActiveRecord::Migration[6.0]
  def change
    rename_column :sequence_steps, :sequence_type, :step_type
    add_column :sequences, :sequence_type, :string
    add_column :sequences, :description, :text
    add_column :sequences, :marketing_type, :string
  end
end
