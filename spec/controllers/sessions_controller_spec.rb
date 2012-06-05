require 'spec_helper'


describe SessionsController do

  let(:user) do
    User.new
  end


  context "POST /create" do
    
    context "successful login" do

      before(:each) do
        User.expects(:authenticate => user)
      end
      
    end

  end
end