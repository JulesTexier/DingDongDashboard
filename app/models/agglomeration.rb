class Agglomeration < ApplicationRecord
  has_many :departments
  has_many :brokers
  has_many :broker_agencies
  has_many :researches
  has_many :subscriber_sequences

  def self.get_agglomeration_from_seloger_ref(sl_ref)
    sl_ref.nil? ? nil : Agglomeration.find_by(ref_code: sl_ref[0..1].upcase)
  end

  def self.opened
    Agglomeration.where(id: Agglomeration.where(is_active: true).select{|a| a.departments.select{|d| d.areas.count > 0}.count > 0}.map(&:id))
  end

  def is_opened?
    Agglomeration.opened.where(id: self.id).empty? ? false : true
  end

  def self.scraped
    Agglomeration.where(id: Agglomeration.all.select{|a| ScraperParameter.where(zone: a.departments.map{|d| d.name}).where(is_active: true).count > 0}.map(&:id))
  end

  def is_scraped?
    Agglomeration.where(id: Agglomeration.all.select{|a| ScraperParameter.where(zone: a.departments.map{|d| d.name}).where(is_active: true).count > 0}.map(&:id)).where(id: self.id).empty? ? false : true
  end
end
