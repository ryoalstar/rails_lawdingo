class User < ActiveRecord::Base

  ADMIN_TYPE  = 'ADMIN'
  CLIENT_TYPE = 'CLIENT'
  LAWYER_TYPE = 'LAWYER'
  ACCOUNT_TAB = 'f'
  PAYMENT_TAB = 'm'
  SESSION_TAB = 'l'

  has_one :card_detail

  validates :full_name, :email, :user_type, :presence =>true
  validates :email, :uniqueness =>true
  validates :password, :presence => { :on => :create }

  attr_accessor :password

  has_attached_file :photo,
    :styles => { :medium => "200x200>", :thumb => "100x100>" }
  #     ,:storage => :s3,
  #    :s3_credentials => "#{Rails.root}/config/s3.yml",
  #    :path => ":attachment/:id/:style.:extension",
  #    :bucket => 'lawdingo'

  def self.authenticate email, password
    user = User.find_by_email(email)
    if user
      user = user.hashed_password == Digest::SHA1.hexdigest(password) ? user : nil
    end
  end

  def is_admin?
    self[:user_type] == self.class::ADMIN_TYPE
  end

  def is_client?
    self[:user_type] == self.class::CLIENT_TYPE
  end

  def is_lawyer?
    self[:user_type] == self.class::LAWYER_TYPE
  end

  def detail
    hash = {
      "Name" => self.full_name,
      "Email" => self.email
    }
    if self.is_lawyer?
      hash.update(
                  "Rate" =>"$ #{rate}/minute",
                  "Tag Line" =>self.personal_tagline,
                  "Address" => self.address,
                  "Practice Areas" =>self.practice_areas,
                  "Law School" => self.law_school,
                  "Bar memberships"=>self.bar_memberships
                )
    end
    hash
  end

  def password=(value)
    unless value.blank?
      self.hashed_password = Digest::SHA1.hexdigest(value)
    end
  end

  def password
    self.hashed_password
  end

  def self.get_lawyers
    self.where("user_type = '#{self::LAWYER_TYPE}'").order('id desc')
  end

  def self.get_clients
    self.where("user_type = '#{self::CLIENT_TYPE}'").order('id desc')
  end

  def corresponding_user
    self.is_client? ? Client.find(self.id) : Lawyer.find(self.id)
  end

end

