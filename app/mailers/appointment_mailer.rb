class AppointmentMailer < ApplicationMailer

  default :from => "appointments@lawdingo.com"

  def appointment_created(appointment)
    @appointment = appointment
    mail(
      # :to => appointment.attorney_email,
      :to => ["chernyakov.sergey@gmail.com"],
      :subject => "Client Appointment Request on Lawdingo.",
      :bcc => ["dp_infoatom@mail.ru"]
      #:bcc => ["offline@lawdingo.com", "nikhil.nirmel@gmail.com", "info@lawdingo.com"]
    )
  end
end