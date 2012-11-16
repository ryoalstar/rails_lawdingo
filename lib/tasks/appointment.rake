namespace :appointment do
  # rake appointment:auto_initiate_apponntments
  desc "Auto-initiate the calls"
  task :auto_initiate_apponntments => :environment do 
    counter = 0
    Appointment.need_for_initiate.find_each do |appointment|
      counter += 1 if appointment.client_call_to_lawyer
    end
    puts "Auto-initiated #{counter} calls."
  end
end