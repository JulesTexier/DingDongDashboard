class AddAssociationToSubscribers < ActiveRecord::Migration[6.0]
  def change
    add_reference :subscribers, :contractor, index: true
    add_reference :subscribers, :notary, index: true
  end
end
