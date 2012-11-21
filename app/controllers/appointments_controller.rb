class AppointmentsController < ApplicationController

  before_filter :authenticate

  # create a new appointment
  def create
    update_client_phone params[:appointment][:contact_number]
    # use for display
    @appointment = AppointmentDecorator.new(
      Appointment.create(params[:appointment].merge(
        :client => current_user.becomes(Client)
      ))
    )
    # our save failed
    respond_to do |format|
      format.json do
        if @appointment.new_record?
          return render(:status => :unprocessable_entity)
        else
          return render(:status => :created)
        end
      end
    end
  end
  
  private
  def update_client_phone phone
    phone = phone.squeeze.gsub(/[^0-9]/, "")
    current_user.update_attribute(:phone, phone) if current_user && phone.length > 0
  end

end

