class TwilioController < ApplicationController

  def twilio_return_voice
    render :file=>"twilio/twilio_return_voice.xml", :content_type => 'application/xml', :layout => false
  end

  def process_gather
    call = Call.find_by_sid(params[:CallSid])
    if params[:Digits].to_i == 1
      call.update_attribute(:status,'connected')
    else
      call.update_attribute(:status, 'rejected')
    end
    @to = params[:To]
    render :file=>"twilio/process_gather.xml", :content_type => 'application/xml', :layout => false
  end

  def call_end_url
    render :text => "", :layout => false
  end

  def fallback
    render :text => "", :layout => false
  end

  def callbackstatus
    render :text => "", :layout => false
  end

end

