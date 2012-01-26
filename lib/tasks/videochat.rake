task :populate_free_consultation_duration => :environment do
  User.where(user_type: 'LAWYER').each do |lawyer|
    lawyer.update_attribute :free_consultation_duration, 15
  end
  puts "\nPopulation done."
end
