class CreateScraperParameters < ActiveRecord::Migration[6.0]
  def change
    create_table :scraper_parameters do |t|
      t.string :url
      t.string :source
      t.string :main_page_cls
      t.string :scraper_type, default: "Static"
      t.string :waiting_cls
      t.boolean :multi_page, default: false
      t.integer :page_nbr, default: 1
      t.string :http_type
      t.text :http_request, array: true, default: []
      t.boolean :is_active, default: true
      t.string :zone
      t.timestamps
    end
  end
end
