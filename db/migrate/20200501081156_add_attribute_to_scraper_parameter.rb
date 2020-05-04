class AddAttributeToScraperParameter < ActiveRecord::Migration[6.0]
  def change
    add_column :scraper_parameters, :group_type, :string
  end
end
