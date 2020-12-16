require 'rails_helper'

RSpec.describe Broker, type: :model do
  describe Subscriber do
    describe "model" do
      describe Broker, '#get_accurate_by_agglomeration' do
        it 'returns accurate broker' do
          
          #setup
          @default_agglomeration = FactoryBot.create(:agglomeration, name: "Default Agglo")
          @agglomeration_paris = FactoryBot.create(:agglomeration, name: "Paris")
          @agglomeration_lyon = FactoryBot.create(:agglomeration, name: "Lyon")
          @agglomeration_bdx = FactoryBot.create(:agglomeration, name: "Bordeaux")
          @agglomeration_mrs = FactoryBot.create(:agglomeration, name: "Marseille")
          @broker_agency_paris_1 = FactoryBot.create(:broker_agency, agglomeration: @agglomeration_paris, max_period_leads: 50, current_period_provided_leads: 20)
          @broker_agency_paris_2 = FactoryBot.create(:broker_agency, agglomeration: @agglomeration_paris, max_period_leads: 100, current_period_provided_leads: 20)
          @broker_agency_lyon = FactoryBot.create(:broker_agency, agglomeration: @agglomeration_lyon, max_period_leads: 100, current_period_provided_leads: 99)
          @broker_agency_bordeaux_test = FactoryBot.create(:broker_agency, agglomeration: @agglomeration_bdx, status: "free")
          @broker_agency_mrs = FactoryBot.create(:broker_agency, agglomeration: @agglomeration_mrs, max_period_leads: 100, current_period_provided_leads: 100)
          @broker_paris_1a = FactoryBot.create(:broker, broker_agency: @broker_agency_paris_1)
          @broker_paris_2a = FactoryBot.create(:broker, broker_agency: @broker_agency_paris_1)
          @broker_paris_2b = FactoryBot.create(:broker, broker_agency: @broker_agency_paris_2)
          @broker_lyon = FactoryBot.create(:broker, broker_agency: @broker_agency_lyon)
          @subscriber = FactoryBot.create(:subscriber, broker: @broker_paris_2a)

          BrokerAgency.create_default
          @default_broker_agency = BrokerAgency.last
          @default_broker = Broker.last
          
          # check integrity
          result = Broker.get_accurate_by_agglomeration(@agglomeration_paris.id)
          expect(result).to be_a Broker

          # check agglomeration
          expect(result.broker_agency.agglomeration).to eq @agglomeration_paris
      
          # check broker_agency (not broker agency in free status)
          result = Broker.get_accurate_by_agglomeration(@agglomeration_lyon.id)
          expect(result.broker_agency).to eq @broker_agency_lyon

          #check broker
          expect(result).to eq @broker_lyon

          # check if it takes good broker agency according to lead repartition
          result = Broker.get_accurate_by_agglomeration(@agglomeration_paris.id)
          expect(result.broker_agency).to eq @broker_agency_paris_2

          # check if it takes good broker according to lead repartition
          expect(result).to eq @broker_paris_2b
          
          # case there is no such agglomeration (=> no Broker Agency hence)
          result = Broker.get_accurate_by_agglomeration(2000)
          # expect(result).not_to be_a Broker
          expect(result).to eq @default_broker

          # check free
          result = Broker.get_accurate_by_agglomeration(@agglomeration_bdx.id)
          # expect(result).not_to be_a Broker
          expect(result).to eq @default_broker
          
          # check full
          # Not implemented, even a full BA will be charged

          # case there is no broker in agency
          result = Broker.get_accurate_by_agglomeration(@agglomeration_mrs)
          # expect(result).not_to be_a Broker
          expect(result).to eq @default_broker
      
        end
      end
    end
  end
end
