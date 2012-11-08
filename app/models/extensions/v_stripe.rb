module Extensions
  module VStripe
    extend ActiveSupport::Concern

    # you can include other things here
    included do
      STRIPE_PLAN_ID = '5' # default
      STRIPE_COUPON_ID = 'dingobaby' # default
      attr_accessor :credit_cards
      attr_accessible :braintree_customer_id
    end

    # include class methods here
    # like User.most_popular
    module ClassMethods
      
     def stripe_create_plan attributes
        Stripe::Plan.create(
          :amount => attributes[:amount],
          :interval => attributes[:interval],
          :name => attributes[:name],
          :currency => attributes[:currency],
          :id => attributes[:id]
        )
      end 
    
      def get_stripe_plan plan_id = STRIPE_PLAN_ID
        Stripe::Plan.retrieve(plan_id)
      end
      
      # we can update name only
      def stripe_update_plan! params, plan_id = STRIPE_PLAN_ID
        stripe_plan = self.get_stripe_plan plan_id
        return false unless stripe_plan
        params.each do |key, value|
          stripe_plan.send("#{key}=", value)  
        end
        stripe_plan.save
      end
    
      def delete_stripe_plan plan_id
        plan = Stripe::Plan.retrieve(plan_id)
        plan.delete if plan.is_a? Stripe::Plan
      end
  
    end

    # include Instance methods
    def update_payment_status
      result = Stripe::Invoice.all(
        :customer => self.stripe_customer_token,
        :paid => false
      )
      self.update_attribute(:payment_status, :unpaid) if result.count > 0
    end  
  
    def create_stripe_card attributes
      create_stripe_customer! unless self.stripe_customer_token
      stripe_card_token = Stripe::Token.create(
        :card => {
        :number => attributes[:number],
        :exp_month => attributes[:exp_month],
        :exp_year => attributes[:exp_year],
        :cvc => attributes[:cvc]
      })
      if stripe_card_token.is_a? Stripe::StripeObject
        self.stripe_card_token = stripe_card_token.id 
        add_card_to_customer
        save!
      end
    end
  
    def create_stripe_test_card!
      self.create_stripe_card(:number => "4242424242424242",:exp_month => 9,:exp_year => 2013,:cvc => 314)
    end
  
    def create_stripe_customer!
      self.create_stripe_customer
      save!
    end 
  
    def create_stripe_customer
      customer = Stripe::Customer.create(
        :description => self.email
      )
      if customer.is_a? Stripe::Customer
        self.stripe_customer_token = customer.id
      end
    end  
  
    def add_card_to_customer
      return false unless self.stripe_card_token
      customer = self.get_stripe_customer
      customer.card = self.stripe_card_token
      customer.save
    end  
  
    def get_stripe_customer
      return nil unless self.stripe_customer_token
      Stripe::Customer.retrieve(self.stripe_customer_token)
    end   
  
    def delete_stripe_customer!
      return false unless self.get_stripe_customer
      customer = self.get_stripe_customer
      customer.delete
      self.stripe_customer_token = nil
      self.stripe_card_token = nil
      save!
    end
  
    def get_stripe_card
      return nil unless self.stripe_card_token
      Stripe::Token.retrieve(self.stripe_card_token)
    end
  
    def delete_stripe_card!
      return false unless self.stripe_card_token
      self.stripe_card_token = nil
      save!
    end
  
    def create_stripe_subscribtion stripe_customer, stripe_plan, stripe_card
      customer = Stripe::Subscription.create( description: self.email, plan: STRIPE_PLAN_ID, card: self.stripe_card_token )
        self.stripe_customer_token = customer.id
        self.stripe_card_token = stripe_card_token
        save!
    end
  
    def cancel_stripe_subscribtion
      customer = self.get_stripe_customer
      return false unless customer
      customer.cancel_subscription
    end
  
 
    def subscribe! plan_id = STRIPE_PLAN_ID
      customer = self.get_stripe_customer
      return false unless customer
      customer.update_subscription(:plan => plan_id)
    end  
  
    def unsubscribe! plan_id = STRIPE_PLAN_ID
      self.cancel_stripe_subscribtion
    end 
  
    def subscribed? plan_id = STRIPE_PLAN_ID
      customer = self.get_stripe_customer
      return false unless customer
      return false unless defined? customer.subscription
      customer.subscription.plan.id == plan_id
    end  
  
    def stripe_get_coupon coupon_id = STRIPE_COUPON_ID
      Stripe::Coupon.retrieve(coupon_id)
    end
  
    def coupon_valid? coupon_id, allow_nil = true
      return true if allow_nil && coupon_id.empty?
      return false if !allow_nil && coupon_id.empty?
      coupon = self.stripe_get_coupon(coupon_id)
      errors.add(:coupon, "That code is invalid.") and return false unless coupon
      true
    rescue Stripe::InvalidRequestError
      errors.add(:coupon, "That code is invalid.") and return false
    end  
  
    def apply_coupon coupon_id, plan_id = STRIPE_PLAN_ID
      return true if coupon_id.empty? # allow blank coupon
      return false unless coupon_valid?(coupon_id)
      customer = self.get_stripe_customer
      coupon = self.stripe_get_coupon(coupon_id)
      return false unless customer && coupon
      customer.update_subscription(:plan => plan_id, :coupon => coupon.id)
    end
  
    def coupon_applied? coupon_id = STRIPE_COUPON_ID
      customer = self.get_stripe_customer 
      coupon = self.stripe_get_coupon(coupon_id)
      return false unless customer && coupon
      return false unless defined? customer.discount.coupon
      customer.discount.coupon.id == coupon.id
    end

  end
end
