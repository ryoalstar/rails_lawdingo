require 'spec_helper'

describe "Restful clients", :integration do
  
  before(:each) do
    Client.delete_all
  end

  context "Signing up" do

    it "should create a client" do
      
      client = FactoryGirl.build(:client)

      lambda{
        visit(new_client_path)
        fill_in("client_first_name", :with => client.first_name)
        fill_in("client_last_name", :with => client.last_name)
        fill_in("client_email", :with => client.email)
        fill_in("client_password", :with => client.password)
        fill_in("client_phone", :with => client.phone)
        click_button("Join Lawdingo")
        
        # base case redirects to lawyers path
        page.current_path.should eql(lawyers_path)

      }.should change{Client.count}.by(1)
    end 

    it "should display error messages when a user fails to be 
      created" do

      client = FactoryGirl.build(:client)

      lambda{
        visit(new_client_path)
        fill_in("client_first_name", :with => client.first_name)
        fill_in("client_last_name", :with => client.last_name)
        fill_in("client_password", :with => client.password)
        click_button("Join Lawdingo")
        
        # should render template with error message
        page.should have_selector("div.error_explanation") do
          with_selector("li", :text => "Email is required")
        end

      }.should change{Client.count}.by(0)

    end
    context "with alert messages" do
      before(:each) do
        @lawyer = FactoryGirl.create(:lawyer)
      end
      it "should persist lawyer alert when going to sign in page" do
        
        visit(new_client_path(:notice=>true, :lawyer_path=>@lawyer.id ))
       
        doc = Nokogiri::HTML(page.html)
        text_message = doc.css("div.notice div.text").first.content

        click_link("Log In")
        
        page.should have_selector("div.notice div.text")
        doc = Nokogiri::HTML(page.html)
        text_message_login = doc.css("div.notice div.text").first.content
       
        text_message.should be_eql text_message_login

      end
      
      it "should persist appointment with notice" do
        visit(new_client_path(:appointment_with=> @lawyer.id))
       
        doc = Nokogiri::HTML(page.html)
        text_message = doc.css("div.notice div.text").first.content
       
        click_link("Log In")
        
        page.should have_selector("div.notice div.text")
        doc = Nokogiri::HTML(page.html)
        text_message_login = doc.css("div.notice div.text").first.content
       
        text_message.should be_eql text_message_login

      end
    end
    

  end

end