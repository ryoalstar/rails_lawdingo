# rake lawyer:reindex
namespace :lawyer do
  desc "Reindex lawyer table for solr: is_available_by_phone, daily_hours_present"
  task :import => :environment do 
  end

  desc "Update lawyer online status"
  task :update_online_status => :environment do 
  	counter = 0
  	Lawyer.where(:is_online => true).where("last_online <= '#{DateTime.now - 5.minutes}'").find_each do |lawyer|
		lawyer.update_attribute(:is_online, false)
		counter += 1
	end
	puts "Updated #{counter} lawyers statuses."
  end
end
