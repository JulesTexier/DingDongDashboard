class AddAgglomerationReferenceToSubscriberSequences < ActiveRecord::Migration[6.0]
  def change
    add_reference :subscriber_sequences, :agglomeration, index: true
  end
end
