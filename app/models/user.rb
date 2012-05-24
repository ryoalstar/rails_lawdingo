class User < ActiveRecord::Base
  ADMIN_TYPE  = 'ADMIN'
  CLIENT_TYPE = 'CLIENT'
  LAWYER_TYPE = 'LAWYER'
  ACCOUNT_TAB = 'f'
  PAYMENT_TAB = 'm'
  SESSION_TAB = 'l'
  PFOFILE_TAB = 'profile'

  # Validate free consultation duration only if it's lawyer signing up
  validates_presence_of :free_consultation_duration, :if => :is_lawyer?

  validates :first_name, :last_name, :email, :user_type, :rate, :presence => true
  validates :email, :uniqueness =>true
  validates :password, :presence => { :on => :create }
  attr_accessor :password, :password_confirmation
  #attr_accessible :email, :password, :password_confirmation

  has_many :offerings
  has_many :questions
  belongs_to :school,
    :touch => true

  has_attached_file :photo,
    :styles => { :medium => "253x253>", :thumb => "102x127>" },
    :storage => :s3,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :s3_protocol => "https",
    :path => "system/:attachment/:id/:style/:basename.:extension"

  def self.authenticate email, password
    user = User.find_by_email(email)
    if user
      user = user.hashed_password == Digest::SHA1.hexdigest(password) ? user : nil
    end
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
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

  def has_video?
    video = Framey::Video.find_by_creator_id(self.id)
    video.present?
  end

  def yelp
    yelp_connection = Yelp::Connection.new
    yelp_connection.find_by_id(self.yelp_business_id)
  end
end

