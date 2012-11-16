require 'csv'
class State < ActiveRecord::Base
  default_scope order("name ASC")

  has_many :bar_memberships
  has_many :lawyers, :through => :bar_memberships
  has_many :messages, :inverse_of => :state
  has_many :appointments, :inverse_of => :state
  FILE_PATH = "#{Rails.root}/states.csv"

  scope :with_approved_lawyers,
    joins(:lawyers)
    .where("#{Lawyer.table_name}.is_approved = ?", true)
    .group("#{table_name}.id")

  scope :name_like, lambda{|name|
    where("#{table_name}.name LIKE ?", name.strip)
  }

  def self.import_csv
    CSV.foreach(FILE_PATH, :headers => true) do |row|
      state = row[0].to_s.split(',')
      self.create(:name => state[0], :abbreviation => state[1])
    end
  end
  
  def name_for_url
    return '' unless self.name
    "#{self.name.squish.gsub(/\s+/,'_')}-lawyers"
  end
  
  def self.name_for_url name
    return '' unless name.to_s.length > 0
    "#{name.to_s.squish.gsub(/\s/,'-')}-lawyers"
  end
end

