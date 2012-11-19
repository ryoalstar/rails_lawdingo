require 'csv'
namespace :lawyer do
  # rake lawyer:import
  # first csv row - model property name
  desc "Import lawyers from csv"
  task :import => :environment do
    counter = 0
    filename = Rails.root.join('lib', 'tasks', 'lawyers', 'lawyers.csv')
    CSV.foreach(filename, { :col_sep => "\t", :headers => :first_row, :return_headers => false }) do |row|
      begin
        lawyer = Lawyer.new(row.to_hash)
        counter += 1 if lawyer.save(:validate => false)
      rescue
      end
    end
    puts "Loaded #{counter} lawyers."
  end

  # rake lawyer:update_online_status
  desc "Update lawyer online status"
  task :update_online_status => :environment do 
  	counter = 0
  	Lawyer.where(:is_online => true).where("last_online <= '#{DateTime.now - 5.minutes}'").find_each do |lawyer|
  		lawyer.update_attribute(:is_online, false)
  		counter += 1
  	end
  	puts "Updated #{counter} lawyers statuses."
  end

  #rake lawyer:update_payment_status
  desc "Update lawyers payment_status"
  task :update_payment_status => :environment do 
    counter = 0
    Lawyer.paid.find_each do |lawyer|
      lawyer.update_payment_status
      counter += 1
    end
    puts "Updated #{counter} lawyers payment_status."
  end  

end
