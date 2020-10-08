class AddAgglomerationReferenceToResearches < ActiveRecord::Migration[6.0]
  def change
    add_reference :researches, :agglomeration, index: true
  end
end
