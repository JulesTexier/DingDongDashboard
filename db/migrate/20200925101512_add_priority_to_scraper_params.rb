class AddPriorityToScraperParams < ActiveRecord::Migration[6.0]
  def change
    add_column :scraper_parameters, :high_priority, :boolean, default: true
  end
end
