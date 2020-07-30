class CreateSavedProperties < ActiveRecord::Migration[6.0]
  def change
    create_table :saved_properties do |t|
      t.belongs_to :research
      t.belongs_to :property
    end
  end
end
