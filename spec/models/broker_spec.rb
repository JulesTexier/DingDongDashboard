require 'rails_helper'

RSpec.describe Broker, type: :model do
  describe Subscriber do
    describe "model" do

      before :all do
        @aurelien = FactoryBot.create(:subscriber_aurelien)
        @melanie = FactoryBot.create(:subscriber_melanie)
        @hugo = FactoryBot.create(:subscriber_hugo)
        @amelie = FactoryBot.create(:subscriber_amelie)
        @veronique = FactoryBot.create(:subscriber_veronique)
        @greg = FactoryBot.create(:broker_greg)
        @etienne = FactoryBot.create(:broker_etienne)

        @sunday_pm = Time.parse('April 19th, 4pm UTC')
        @monday_am = Time.parse('April 20th, 7am UTC')
        @monday_pm = Time.parse('April 20th, 1pm UTC')
        @monday_evening = Time.parse('April 20th, 20:02pm UTC')
        @tuesday_am = Time.parse('April 21st, 7am UTC')
        @tuesday_pm = Time.parse('April 21st, 1pm UTC')
        @tuesday_evening = Time.parse('April 21st, 20:02pm UTC')
        @wednesday_am = Time.parse('April 22nd, 7am UTC')
        @wednesday_pm = Time.parse('April 22nd, 1pm UTC')
        @wednesday_evening = Time.parse('April 22nd, 20:02pm UTC')
        @thursday_am = Time.parse('April 23rd, 7am UTC')
        @thursday_pm = Time.parse('April 23rd, 1pm UTC')
        @thursday_evening = Time.parse('April 23rd, 20:02pm UTC')
        @friday_am = Time.parse('April 24th, 7am UTC')
        @friday_pm = Time.parse('April 24th, 1pm UTC')
        @friday_evening = Time.parse('April 24th, 20:02pm UTC')

      end

      context "returned Broker for regular acquisiton" do
        it "should return Hugo" do
          # Créneau 1 : WE et lundi matin
          expect(Broker.get_current_broker(@sunday_pm).trello_username).to eq(@hugo.trello_username)
          expect(Broker.get_current_broker(@monday_am).trello_username).to eq(@hugo.trello_username)
          expect(Broker.get_current_broker(@monday_pm).trello_username).not_to eq(@hugo.trello_username)

          # Créneau 2 : Mercredi matin
          expect(Broker.get_current_broker(@tuesday_evening).trello_username).to eq(@hugo.trello_username)
          expect(Broker.get_current_broker(@wednesday_am).trello_username).to eq(@hugo.trello_username)
          expect(Broker.get_current_broker(@wednesday_pm).trello_username).not_to eq(@hugo.trello_username)
          expect(Broker.get_current_broker(@friday_pm).trello_username).to eq(@hugo.trello_username)

        end
        it "should return Veronique" do
          # Créneau 1 : Lundi aprem
          expect(Broker.get_current_broker(@monday_pm).trello_username).to eq(@veronique.trello_username)
          expect(Broker.get_current_broker(@monday_evening).trello_username).not_to eq(@veronique.trello_username)

          # Créneau 2 : Vendredi aprem
          # expect(Broker.get_current_broker(@friday_pm).trello_username).to eq(@veronique.trello_username)
          expect(Broker.get_current_broker(@friday_evening).trello_username).not_to eq(@veronique.trello_username)
        end
        it "should return Aurélien" do
          # Créneau 1 : Mardi matin
          expect(Broker.get_current_broker(@monday_evening).trello_username).to eq(@aurelien.trello_username)
          expect(Broker.get_current_broker(@tuesday_am).trello_username).to eq(@aurelien.trello_username)
          expect(Broker.get_current_broker(@tuesday_pm).trello_username).not_to eq(@aurelien.trello_username)

          # Créneau 2 : Jeudi aprem
          expect(Broker.get_current_broker(@thursday_pm).trello_username).to eq(@aurelien.trello_username)
          expect(Broker.get_current_broker(@thursday_evening).trello_username).not_to eq(@aurelien.trello_username)
        end
        it "should return Melanie" do
          # Créneau 1 : Mardi aprem
          expect(Broker.get_current_broker(@tuesday_pm).trello_username).to eq(@melanie.trello_username)
          expect(Broker.get_current_broker(@tuesday_evening).trello_username).not_to eq(@melanie.trello_username)

          # Créneau 2 : Jeudi matin
          expect(Broker.get_current_broker(@wednesday_evening).trello_username).to eq(@melanie.trello_username)
          expect(Broker.get_current_broker(@thursday_am).trello_username).to eq(@melanie.trello_username)
          expect(Broker.get_current_broker(@thursday_pm).trello_username).not_to eq(@melanie.trello_username)
        end
        it "should return Amélie" do
          # Créneau 1 : Mercredi aprem
          expect(Broker.get_current_broker(@wednesday_pm).trello_username).to eq(@amelie.trello_username)
          expect(Broker.get_current_broker(@wednesday_evening).trello_username).not_to eq(@amelie.trello_username)

          # Créneau 2 : Vendredi matin
          expect(Broker.get_current_broker(@thursday_evening).trello_username).to eq(@amelie.trello_username)
          expect(Broker.get_current_broker(@friday_am).trello_username).to eq(@amelie.trello_username)
          expect(Broker.get_current_broker(@friday_pm).trello_username).not_to eq(@amelie.trello_username)
        end
      end

      context "returned Broker for subscription acquisiton" do

        it "should return Etienne" do
          # Créneau 1 : Lundi aprem
          expect(Broker.get_current_broker_subscription_bm(@monday_pm).trello_username).to eq(@etienne.trello_username)
          # expect(Broker.get_current_broker_subscription_bm(@monday_evening).trello_username).not_to eq(@greg.trello_username)

          # Créneau 2 : Vendredi aprem
          expect(Broker.get_current_broker_subscription_bm(@friday_pm).trello_username).to eq(@etienne.trello_username)
          # expect(Broker.get_current_broker_subscription_bm(@friday_evening).trello_username).not_to eq(@aurelien.trello_username)

          # Créneau 3 : Mardi aprem
          expect(Broker.get_current_broker_subscription_bm(@tuesday_pm).trello_username).to eq(@etienne.trello_username)
          # expect(Broker.get_current_broker_subscription_bm(@tuesday_evening).trello_username).not_to eq(@aurelien.trello_username)

          # Créneau 4 : Jeudi matin
          expect(Broker.get_current_broker_subscription_bm(@wednesday_evening).trello_username).to eq(@etienne.trello_username)
          expect(Broker.get_current_broker_subscription_bm(@thursday_am).trello_username).to eq(@etienne.trello_username)
          # expect(Broker.get_current_broker_subscription_bm(@thursday_pm).trello_username).not_to eq(@greg.trello_username)
          
          # Créneau 5 : Mercredi aprem
          expect(Broker.get_current_broker_subscription_bm(@wednesday_pm).trello_username).to eq(@etienne.trello_username)
          # expect(Broker.get_current_broker_subscription_bm(@wednesday_evening).trello_username).not_to eq(@aurelien.trello_username)

          # Créneau 6 : Vendredi matin
          expect(Broker.get_current_broker_subscription_bm(@thursday_evening).trello_username).to eq(@etienne.trello_username)
          expect(Broker.get_current_broker_subscription_bm(@friday_am).trello_username).to eq(@etienne.trello_username)
          # expect(Broker.get_current_broker_subscription_bm(@friday_pm).trello_username).not_to eq(@aurelien.trello_username)

          # Créneau 7 : WE et lundi matin
          expect(Broker.get_current_broker_subscription_bm(@sunday_pm).trello_username).to eq(@etienne.trello_username)
          expect(Broker.get_current_broker_subscription_bm(@monday_am).trello_username).to eq(@etienne.trello_username)
          # expect(Broker.get_current_broker_subscription_bm(@monday_pm).trello_username).not_to eq(@aurelien.trello_username)

          # Créneau 8 : Mercredi matin
          expect(Broker.get_current_broker_subscription_bm(@tuesday_evening).trello_username).to eq(@etienne.trello_username)
          expect(Broker.get_current_broker_subscription_bm(@wednesday_am).trello_username).to eq(@etienne.trello_username)
          # expect(Broker.get_current_broker_subscription_bm(@wednesday_pm).trello_username).not_to eq(@aurelien.trello_username)
          expect(Broker.get_current_broker_subscription_bm(@friday_pm).trello_username).to eq(@etienne.trello_username)
        end
        it "should return Etienne" do
          # Créneau 1 : Mardi matin
          expect(Broker.get_current_broker_subscription_bm(@monday_evening).trello_username).to eq(@etienne.trello_username)
          expect(Broker.get_current_broker_subscription_bm(@tuesday_am).trello_username).to eq(@etienne.trello_username)
          # expect(Broker.get_current_broker_subscription_bm(@tuesday_pm).trello_username).not_to eq(@aurelien.trello_username)

          # Créneau 2 : Jeudi aprem
          expect(Broker.get_current_broker_subscription_bm(@thursday_pm).trello_username).to eq(@etienne.trello_username)
          # expect(Broker.get_current_broker_subscription_bm(@thursday_evening).trello_username).not_to eq(@aurelien.trello_username)
        end

      end
    end
  end
end
