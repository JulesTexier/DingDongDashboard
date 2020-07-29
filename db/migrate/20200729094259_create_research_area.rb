class CreateResearchArea < ActiveRecord::Migration[6.0]
  def change
    create_table :research_areas do |t|
      t.belongs_to :area
      t.belongs_to :research
    end
  end
end
