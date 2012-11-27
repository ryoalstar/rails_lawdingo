require 'spec_helper'

describe AppointmentMailer do

  let(:decorator) do
    AppointmentDecorator.new(appointment)
  end

  let(:appointment) do
    client = Client.new.tap do |a|
      a.stubs({:email => "client@test.com", :first_name => 'A. Client'})
    end
    lawyer = Lawyer.new.tap do |a|
      a.stubs({:email => "lawyer@test.com", :first_name => 'A. Lawyer'})
    end
    
    Appointment.new.tap do |a|
      a.stubs({
        :time => Time.zone.parse("2011-01-01 15:00:00"),
        :message => "Hi there",
        :free_minutes => 10,
        :per_minute_rate => 1.5,
        :client => client,
        :lawyer => lawyer
      })
    end
  end

  context "#notify_lawyer_about_appointment_created" do

    it "should display the appointment details for lawyer" do
      mailer = AppointmentMailer.notify_lawyer_about_appointment_created(decorator)
      mailer.subject.should eql "Client Appointment Request on Lawdingo"
      mailer.to.should eql(["lawyer@test.com"])
      mailer.body.should =~ /Hi there/
      mailer.body.should =~ /A. Client/
      mailer.body.should =~ /3:00pm EST Saturday, 1\/1/
      mailer.body.should =~ /10 minutes will be free/
      mailer.body.should =~ /will earn \$1.50 per minute/
    end
    
    it "should display the appointment details for client" do
      mailer = AppointmentMailer.notify_client_about_appointment_created(decorator)
      mailer.subject.should eql "You've requested Appointment on Lawdingo"
      mailer.to.should eql(["client@test.com"])
      mailer.body.should =~ /Hi there/
      mailer.body.should =~ /A. Client/
      mailer.body.should =~ /3:00pm EST Saturday, 1\/1/
      mailer.body.should =~ /10 minutes will be free/
      mailer.body.should =~ /will be charged \$1.50 per minute/
    end

  end

end