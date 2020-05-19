class AddContentSubjectToSequenceStep < ActiveRecord::Migration[6.0]
  def change
    add_column :sequence_steps, :content, :text
    add_column :sequence_steps, :subject, :string
  end
end
