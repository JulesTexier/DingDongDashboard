class Agglomeration < ApplicationRecord
  has_many :departments
  has_many :brokers
  has_many :researches
  has_many :subscriber_sequences

  def get_agglomeration_from_seloger_ref(sl_ref)
    x_ref = YAML.load_file("db/data/agglomeration.yml")
    code_agglo = sl_ref[0..1]
    Agglomeration.find_by(ref_code: code_agglo)
  end
end
