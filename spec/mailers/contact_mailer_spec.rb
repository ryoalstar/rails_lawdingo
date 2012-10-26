require 'spec_helper'

describe AppointmentMailer do
  context "#send_mail" do

    it "should display the appointment details" do
      mailer = ContactMailer.contact_email('User Name', 'test@mail.com','Message')
      mailer.subject.should eql "Message from contact form"
      mailer.to.should eql(["nikhil.nirmel@gmail.com"])
      mailer.body.should =~ /User Name/
      mailer.body.should =~ /test@mail.com/
      mailer.body.should =~ /Message/
    end

  end
  
  context "#new_subscriber" do

    it "should display the subscriber details" do
      mailer = ContactMailer.new_subscriber('test@mail.com')
      mailer.subject.should eql "New subscriber"
      mailer.to.should eql(["nikhil.nirmel@gmail.com"])
      mailer.body.should =~ /test@mail.com/
    end

  end
end