require "rails_helper"

RSpec.describe SubscribersController, type: :controller do
  before(:all) do
    area_yaml = YAML.load_file("db/data/areas.yml")
    area_yaml.each do |district_data|
      district_data["datas"].each do |data|
        FactoryBot.create(:area, name: data["name"], zone: district_data["zone"])
      end
    end
  end
  describe "GET #edit" do
    before do
      sub = FactoryBot.create(:subscriber_dummy_fb_id)
      sub.areas << Area.first
      get :edit, params: { id: sub.id }
    end
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
    it "renders the edit template" do
      expect(response).to render_template("edit")
    end
  end
end
