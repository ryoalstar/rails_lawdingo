class User < ActiveRecord::Base

  ADMIN_TYPE  = 'ADMIN'
  CLIENT_TYPE = 'CLIENT'
  LAWYER_TYPE = 'LAWYER'
  ACCOUNT_TAB = 'f'
  PAYMENT_TAB = 'm'
  SESSION_TAB = 'l'

  # Validate free consultation duration only if it's lawyer signing up
  validates_presence_of :free_consultation_duration, :if => :is_lawyer?

  validates :first_name, :last_name, :email, :user_type, :rate, :presence => true
  validates :email, :uniqueness =>true
  validates :password, :presence => { :on => :create }
  attr_accessor :password

  has_many :offerings

  has_attached_file :photo,
    :styles => { :medium => "232x", :thumb => "100x" },
      :storage => :s3,
      :s3_credentials => "#{Rails.root}/config/s3.yml",
      :path => "system/:attachment/:id/:style/:basename.:extension"

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

  def save_stripe_customer_id token_id
    status = false
    if self.update_attribute(:stripe_customer_token, token_id)
      status = true
    end
    status
  end

  def get_stripe_customer_id
    self.stripe_customer_token
  end

  def is_lawyer?
    self[:user_type] == self.class::LAWYER_TYPE
  end

  def detail
    hash = {
      "First Name" => self.first_name,
      "Last Name" => self.last_name,
      "Email" => self.email
    }
    if self.is_lawyer?
      hash.update(
                  "Rate" =>"$ #{rate}/minute",
                  "Tag Line" =>self.personal_tagline,
                  "Address" => self.address,
                  "Practice Areas" =>self.corresponding_user.practice_areas,
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

  def full_name
    "#{self.first_name} #{self.last_name}"
  end
end

