class AppointmentMailer < ApplicationMailer

  default :from => "'Lawdingo Appointments' <appointments@lawdingo.com>",
    :bcc => ["offline@lawdingo.com", "nikhil.nirmel@gmail.com", "info@lawdingo.com"]

  def notify_lawyer_about_appointment_created(appointment)
    @appointment = appointment
    mail(
      :to => appointment.lawyer.email,
      :subject => "Client Appointment Request on Lawdingo"
    )
  end
  
  def notify_client_about_appointment_created(appointment)
    @appointment = appointment
    mail(
      :to => appointment.client.email,
      :subject => "You've requested Appointment on Lawdingo"
    )
  end
end