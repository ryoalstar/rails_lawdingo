class CardDetail < ActiveRecord::Base
   validates :card_number, :expire_month, :expire_year, :card_verification, :presence =>true

  belongs_to :user
  after_initialize :set_default_values

  after_save :update_user_status
  before_destroy :update_user_payment_status

  def update_user_status
    user = self.user
    if user
      user.update_attribute(:has_payment_info, true)
    end
  end

  def update_user_payment_status
    user = self.user
    if user
      user.update_attribute(:has_payment_info, false)
    end
  end

  def self.test_stripe
    card_detail = CardDetail.last
    # create the charge on Stripe's servers - this will charge the user's card
    charge = Stripe::Charge.create(
      :amount => 1500, # amount in cents, again
      :currency => "usd",
      :card => {
        :number => card_detail.card_number,
        :exp_month => card_detail.expire_month,
        :exp_year => card_detail.expire_year,
        :cvc => card_detail.card_verification,
        #:name => card_detail.first_name + ' ' + card_detail.last_name,
        #:addresss_line1 => card_detail.street_address ,
        #:address_zip => card_detail.postal_code,
        #:address_state => card_detail.state ,
        #:address_country => card_detail.country,
      },
      :description => "lawdingo@gmail.com"
    )
  end


  private

  def set_default_values
    #self.first_name ||= 'First Name'
    #self.last_name ||= 'Last Name'
    #self.street_address ||= 'Street Address'
    #self.city ||= 'City'
    #self.state ||= 'State'
    #self.postal_code ||= 'Postal Code'
    self.card_number ||= 'Credit Card Number'
    self.card_verification ||= 'Security Code'
    #self.country ||= 'United States'
  end
end

