require 'spec_helper'

describe ContactController do
  context "GET #index" do
    it "should respond with success" do
      get :index
      response.should be_success
    end
  end
  
  context "Send email" do
    it "should flag an error when one of the fields is missing" do
      xhr :post, :send_email, :name => 'name', :email=>nil, :message=>'Message'
      assigns(:error).should be_true
      
      xhr :post, :send_email, :name => 'name', :email=>'test@mail.com', :message=>''
      assigns(:error).should be_true
      
      xhr :post, :send_email, :name => '', :email=>'test@mail.com', :message=>'Message'
      assigns(:error).should be_true      
    end
    
    it "should not flag an error when none of the fields is missing" do
      xhr :post, :send_email, :name => 'name', :email=>'test@mail.com', :message=>'Message'
      assigns(:error).should be_false
    end
  end
  
  
  context "Subscription" do
    it "should flag an error when email is missing" do
      xhr :post, :new_subscriber, :email=>nil
      assigns(:error).should be_true
    end
    it "should not flag an error when email is not missing" do
      xhr :post, :new_subscriber, :email=>'test@mail.com'
      assigns(:error).should_not be_true
    end
  end
    
end
