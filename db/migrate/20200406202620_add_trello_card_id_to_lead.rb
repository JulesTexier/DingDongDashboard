class AddTrelloCardIdToLead < ActiveRecord::Migration[6.0]
  def change
    add_column :leads, :trello_id_card, :string
  end
end
