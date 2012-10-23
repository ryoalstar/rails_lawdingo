class AppParameter < ActiveRecord::Base

  CHARGE_PER_MINUTE       = 'charge per minute'
  CHARGE_PER_MINUTE_VALUE = '1.0'
  HOMEPAGE_TAG_LINE       = 'Homepage Tag Line'
  HOMEPAGE_TAG_LINE_VALUE = 'Sound legal advice from lawyers over video chat for however long you need'
  LAWYER_MOUNTLY_FEE      = 'The lawyer subscription monthly fee'
  LAWYER_MOUNTLY_FEE_VALUE= 92

  def self.set_defaults
    param = self.find_or_create_by_name CHARGE_PER_MINUTE
    param.update_attribute(:value,CHARGE_PER_MINUTE_VALUE)
    param = self.find_or_create_by_name HOMEPAGE_TAG_LINE
    param.update_attribute(:value,HOMEPAGE_TAG_LINE_VALUE)
    self.lawyer_mountly_fee=LAWYER_MOUNTLY_FEE_VALUE
  end
  
  def self.lawyer_mountly_fee=(lawyer_mountly_fee = LAWYER_MOUNTLY_FEE_VALUE)
    param = self.find_or_create_by_name LAWYER_MOUNTLY_FEE
    param.update_attribute(:value, LAWYER_MOUNTLY_FEE_VALUE)
    #Lawyer::stripe_update_plan!(:amount => lawyer_mountly_fee)
  end
  
  def self.lawyer_mountly_fee
    lawyer_mountly_fee = self.find_by_name LAWYER_MOUNTLY_FEE
    lawyer_mountly_fee_value = lawyer_mountly_fee ? lawyer_mountly_fee.value : LAWYER_MOUNTLY_FEE_VALUE
    lawyer_mountly_fee_value.to_f
  end

  def self.service_charge_value
    charge = self.find_by_name(self::CHARGE_PER_MINUTE)
    charge_value = charge ? charge.value : '0.75'
    charge_value.to_f
  end

  def self.service_homepage_tagline
    tag = self.find_by_name(self::HOMEPAGE_TAG_LINE)
    return tag ? tag.value : ''
  end

  class << self
    def service_homepage_subtext
      subtext = {}
      subtext[:first] = find_by_name("Homepage Subtext #1").try(:value)
      subtext[:second] = find_by_name("Homepage Subtext #2").try(:value)
      return subtext
    end
  end


end

