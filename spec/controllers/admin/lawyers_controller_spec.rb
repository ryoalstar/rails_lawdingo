require 'spec_helper'

describe Admin::LawyersController do
  context "#Admin should see list of users Lawyer list" do
      before :each do
        @admin = FactoryGirl.create(:admin)
        session[:user_id] = @admin.id 
      end
      
      it "response should success" do
          get 'index'
          response.should be_success
      end
      
    end
end  
  
  
