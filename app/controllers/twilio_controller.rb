class TwilioController < ApplicationController

  def twilio_return_voice
    render :file=>"twilio/twilio_return_voice.xml", :content_type => 'application/xml', :layout => false
  end

  def process_gather
    @call = Call.find_by_sid(params[:CallSid])
    if params[:Digits].to_i == 1
      @call.update_attribute(:status,'connected')
    else
      @call.update_attribute(:status, 'ignored')
      @call.hangup
    end
    render :file=>"twilio/process_gather.xml", :content_type => 'application/xml', :layout => false
  end

  def dial_callback
    if params[:DialCallStatus] == 'completed'
    else
      @call = Call.find_by_sid(params[:CallSid])
      @call.update_attribute(:status, 'disconnected')
    end
    render :file=>"twilio/dial_response.xml", :content_type => 'application/xml', :layout => false
  end

  def call_end_url
    render :text => "", :layout => false
  end

  def fallback
    render :text => "", :layout => false
  end

  def callbackstatus
    @call = Call.find_by_sid(params[:CallSid])
    @call.update_attribute(:end_date, Time.now)
    input_params = Hash.new
    input_params[:client_id] = @call.client_id
    input_params[:lawyer_id] = @call.lawyer_id
    input_params[:start_date] = @call.start_date
    input_params[:end_date] = @call.end_date
    billable_time = @call.billing_start_time.present? ? (@call.end_date - @call.billing_start_time).ceil : 0
    input_params[:billable_time] = billable_time
#    conversation = Conversation.create_conversation(input_params)
#    @call.update_attribute(:status, 'completed')
    render :text => "", :layout => false
  end

end

