class TwilioController < ApplicationController
  before_filter :obtain_call, only: [:welcome, :goodbye, :hangup, :callback, :check_call_status, :update_call_status]
  before_filter :create_client, only: [:welcome, :dial_lawyer, :hangup]

  def welcome
    # Connect client to conference
    response = Twilio::TwiML::Response.new do |r|
      r.Say "Hello!"
      r.Redirect twilio_conference_url(
        opening_words: opening_words,
        room_name: conference_room_name(params[:lawyer_number])
      ), method: "POST"
    end

    # Call lawyer if we've already connected with client
    # and define call as connected
    if params[:client_number].present?
      @call.update_status :connected
      dial_lawyer(params[:lawyer_number])
    end

    render text: response.text, layout: false
  end

  def connect_to_conference
    response = Twilio::TwiML::Response.new do |r|
      r.Say params[:opening_words] if params[:opening_words].present?
      r.Dial action: twilio_goodbye_url do |d|
        d.Conference params[:room_name], endConferenceOnExit: true
      end
    end

    render text: response.text, layout: false
  end

  def dial_lawyer(lawyer_number)
    # TODO: Dial lawyer only if the client is already in a conference room
    # ERROR: @current_conference object returns Nil
    # @current_conference = @client.account.conferences.list({ friendly_name: conference_room_name }).first

    # if @current_conference.participants.list({}).count > 0
      @call = @client.account.calls.create(
        from: Twilio::FROM,
        to: lawyer_number,
        url: twilio_welcome_url(lawyer_number: params[:lawyer_number]),
        fallbackurl: twilio_fallback_url
      )
    # end
  end

  def goodbye
    # TODO: Sometimes @call returns Nil, try to pass the call sid through 
    # welcome -> dial_lawyer -> goodbye, because the DialCallSid is not provided
    # in a Twilio API request after connecting to the conference
    if @call.present?
      @call.update_status :disconnected unless params[:DialCallStatus] == "completed"
    end

    response = Twilio::TwiML::Response.new do |r|
      r.Say "Goodbye.", voice: "woman"
    end

    render text: response.text, layout: false
  end

  def fallback
    render nothing: true
  end

  def callback
    @call.update_attributes(
      end_date: Time.now,
      call_duration: params[:CallDuration]
    )

    @conversation = Conversation.create_conversation(
      client_id: @call.client_id,
      lawyer_id: @call.lawyer_id,
      start_date: @call.start_date,
      end_date: @call.end_date,
      consultation_type: "phone",
      billable_time: @call.billable_time
    )

    @call.update_status :completed
    @call.update_attributes(conversation_id: @conversation.id)

    render nothing: true
  end

  def hangup
    # Since conference endConferenceOnExit param is set to true,
    # the conference will finish once the client hangs up
    @client.account.calls.get(params[:call_id]).hangup if params[:call_id].present?

    @call.update_status :disconnected

    render nothing: true
  end

  def check_call_status
    # Pass the call status to HTTP response headers
    headers["call-status"] = @call.status

    case @call.status
    when "dialing", "connected", "billed"
    when "completed"
      # TODO: Redirect to the review/report form depending on the call disconnection
      # unless (@call.call_duration == 0)
      #   form = "review"
      # else
      #   form = "report"
      # end
      form = "review"

      render js: "window.location = '#{conversation_summary_path(@call.conversation, call_type: "phonecall", form: form)}'", notice: "Your call is completed."
    else
      create_call_conversation_unless_its_present
      render js: "window.location = '#{conversation_summary_path(@call.conversation, call_type: "phonecall", form: "review")}'"
    end
  end

  def update_call_status
    if params[:sb].to_i == 1
      if current_user.stripe_customer_token.present?
        @call.update_status :billed
        @call.update_attributes(billing_start_time: Time.now)
      else
        hangup
      end
    end
  end


  private

  # Get the call object whether it's required from twilio response
  # or from users#create_phone_call view
  def obtain_call
    if params[:CallSid].present?
      call_sid = params[:CallSid]
    else
      call_sid = params[:call_id]
    end

    @call = Call.find_by_sid(call_sid)
  end

  def create_client
    @client = Twilio::REST::Client.new(Twilio::ACCOUNT_SID, Twilio::AUTH_TOKEN)
  end

  def create_call_conversation_unless_its_present
    unless @call.conversation.present?
      # If the call is somehow failed, update it's end_date and duration
      # before creating a conversation
      if ["ignored", "disconnected"].include?(@call.status)
        @call.update_attributes(
          end_date: Time.now,
          call_duration: params[:CallDuration]
        )
      end

      conversation = Conversation.create_conversation(
        client_id: @call.client_id,
        lawyer_id: @call.lawyer_id,
        start_date: @call.start_date,
        end_date: @call.end_date,
        consultation_type: "phone",
        billable_time: @call.billable_time
      )

      # Relate created conversation to the call
      @call.update_attributes(conversation_id: conversation.id)
    end
  end

  # Select opening words depending on whether we've already 
  # connected with client or not
  def opening_words
    if params[:client_number].present?
      opening_words = "Please wait while we reach the lawyer."
    else
      opening_words = "A client from Lawdingo is on the line. Say hello."
    end
  end

  # Define conference room name with lawyer's number,
  # which seems to be unique
  def conference_room_name(lawyer_number)
    number = lawyer_number || params[:lawyer_number]
    "Lawdingo Room ##{number}"
  end
end
