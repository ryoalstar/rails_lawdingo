require 'csv'
class State < ActiveRecord::Base
  has_many :bar_memberships
  has_many :lawyers, :through => :bar_memberships
  FILE_PATH = "#{Rails.root}/states.csv"

  def self.import_csv
    CSV.foreach(FILE_PATH, :headers => true) do |row|
      state = row[0].to_s.split(',')
      self.create(:name => state[0], :abbreviation => state[1])
    end
  end

end

