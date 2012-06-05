class AppointmentsController < ApplicationController

  before_filter :authenticate

  # create a new appointment
  def create
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
          begin
            AppointmentMailer.appointment_created(@appointment).deliver
          rescue => e
            debugger
            true
          end
          return render(:status => :created)
        end
      end
    end
  end

end
