class Conversation < ActiveRecord::Base

  belongs_to :client
  belongs_to :lawyer
  
  after_create :process_payment

  def self.create_conversation input_params
    #    client_id       = input_params[:client_id]
    #    lawyer_id       = input_params[:lawyer_id]
    #    start_date      = input_params[:start_date]
    #    end_date        = input_params[:end_date]
    #    billable_time   = input_params[:billable_time]
    lawdingo_charge = AppParameter.service_charge_value
    
    client_id       = 2
    lawyer_id       = 1
    start_date      = Time.now
    end_date        = Time.now + 1888
    billable_time   = ((end_date - start_date)/60).round

    begin
      lawyer = Lawyer.find(lawyer_id)
    rescue
      lawyer = nil
    end
    
    if lawyer
      billing_rate  = lawyer.rate
      # calculate billing amount
      billed_amount = billable_time * billing_rate + lawdingo_charge

      conversation = self.create(:client_id =>client_id, :lawyer_id =>lawyer_id, :lawyer_rate =>billing_rate,
        :start_date =>start_date, :end_date =>end_date,:billable_time =>billable_time,
        :lawdingo_charge =>lawdingo_charge, :billed_amount =>billed_amount  )
    else
      conversation = nil
    end
    conversation
  end

  def lawyer_name
    lawyer = self.lawyer
    lawyer ? lawyer.full_name : "-"
  end

  def client_name
    client = self.client
    client ? client.full_name : "-"
  end

  # in minute
  def duration
    ((self.end_date - self.start_date)/60).round
  end

  def lawyer_earning
    self.billed_amount - self.lawdingo_charge
  end

  # in seconds
  def billed_time
    self.billable_time
  end

  #--------------- Payment Part ---------------------#
  def process_payment
    begin
      user = User.find(self.client_id)
    rescue
      user = nil
    end
    if user
      payment_obj = self.class.process_card user.card_detail, self.id, self.billed_amount
      # change payment status
      self.update_attributes(:has_been_charged => true, :payment_params =>payment_obj.to_json) if payment_obj
    end
  end

  # actual process for payment
  def self.process_card card_detail, conversation_id = 1, billed_amount = 10
    begin     
      # create the charge on Stripe's servers - this will charge the user's card
      charge = Stripe::Charge.create(        
        :card => {                
          :number           => card_detail.card_number,
          :exp_month        => card_detail.expire_month,
          :exp_year         => card_detail.expire_year,
          :cvc              => card_detail.card_verification,
          :name             => card_detail.first_name + ' ' + card_detail.last_name,
          :addresss_line1   => card_detail.street_address ,
          :address_zip      => card_detail.postal_code,
          :address_state    => card_detail.state ,
          :address_country  => card_detail.country,
        },
        :amount             => (billed_amount * 100).to_i, # amount in cents
        :currency           => "usd",
        :description        => "Charge for conversation with id: #{conversation_id}"
      )            
    rescue Exception =>exp
      charge = nil
      logger.error("Unable to charge conversation with id: #{conversation_id}\n" + exp.message)
    end
    charge
  end

  #--------------------------------------------------#
end
