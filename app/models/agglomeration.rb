class Agglomeration < ApplicationRecord
  has_many :departments
  has_many :brokers
  has_many :researches
  has_many :subscriber_sequences

  def self.get_agglomeration_from_seloger_ref(sl_ref)
    sl_ref.nil? ? nil : Agglomeration.find_by(ref_code: sl_ref[0..1].upcase)
  end
end
