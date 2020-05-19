require "rails_helper"
require "dotenv/load"

RSpec.describe Api::V1::WebhooksController, type: :controller do
  context "#handle_website/form_link_clicked" do
    before(:all) do
      @sub = FactoryBot.create(:subscriber)
      @s = FactoryBot.create(:sequence)
      @ss = FactoryBot.create(:sequence_step, sequence: @s)
    end

    it "should create a status name with website_clicked" do
      post :handle_website_link_clicked, params: { "id" => @sub.id, "ss" => @ss.id }
      expect(Status.last.name).to eq("sequence_1_step_1_website_clicked")
      expect(Status.all.count).to eq(2)
    end

    it "should find a status named sequence_1_step_1_website_clicked" do
      FactoryBot.create(:status, name: "sequence_1_step_1_website_clicked")
      post :handle_website_link_clicked, params: { "id" => @sub.id, "ss" => @ss.id }
      expect(Status.last.name).to eq("sequence_1_step_1_website_clicked")
      expect(Status.all.count).to eq(2) # not equal to 3 because nothing has been created, but the status has been retrieved
    end

    it "shouldnt create anything" do
      post :handle_website_link_clicked, params: {}
      expect(Status.last).not_to eq("sequence_1_step_1_website_clicked")
      expect(Status.all.count).to eq(1) #nothing has been created
    end

    it "should create a status name with form_clicked" do
      post :handle_form_link_clicked, params: { "id" => @sub.id, "ss" => @ss.id }
      expect(Status.last.name).to eq("sequence_1_step_1_form_clicked")
      expect(Status.all.count).to eq(2)
    end

    it "shouldnt create anything" do
      post :handle_form_link_clicked, params: {}
      expect(Status.last).not_to eq("sequence_1_step_1_form_clicked")
      expect(Status.all.count).to eq(1)
    end

    it "should find a status named sequence_1_step_1_website_clicked" do
      FactoryBot.create(:status, name: "sequence_1_step_1_form_clicked")
      post :handle_form_link_clicked, params: { "id" => @sub.id, "ss" => @ss.id }
      expect(Status.last.name).to eq("sequence_1_step_1_form_clicked")
      expect(Status.all.count).to eq(2) # not equal to 3 because nothing has been created, but the status has been retrieved
    end
  end
end
