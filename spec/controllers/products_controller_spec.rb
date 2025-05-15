require "rails_helper"
require_relative "../support/controller_macros"

RSpec.describe ProductsController, type: :controller do
  describe "GET /" do
         before(:each) do
                @request.env["devise.mapping"] = Devise.mappings[:user]
                user = FactoryBot.create(:user)
                sign_in user
            end
        context "from login user" do
                    it "should return 200:OK" do
                        get :index
                        expect(response).to have_http_status(:ok)
                    end
        end
    end
  end
