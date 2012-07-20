class Bid < ActiveRecord::Base
  belongs_to :inquiry
  belongs_to :lawyer

  attr_accessor :stripe_card_token

  default_scope order("amount ASC")

  def save_with_payment
    if valid?
      unless lawyer.stripe_customer_token.present?
        customer = Stripe::Customer.create(description: lawyer.email, card: stripe_card_token)
        # Solr fires a 500 error if token is updates though Lawyer object
        # lawyer.update_attribute(:stripe_customer_token, stripe_card_token)
        User.find(lawyer.id).update_attribute(:stripe_customer_token, stripe_card_token) 
        save!
      else
        save!
      end
    end
  rescue Stripe::InvalidRequestError => e
    logger.error "Stripe error while creating customer: #{e.message}"
    errors.add :base, "There was a problem with your credit card."
    false
  end
end
