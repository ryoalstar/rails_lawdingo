class AppointmentDecorator < ApplicationDecorator

  decorates :appointment,
    :class => "Appointment"

  def per_minute_rate
    h.number_to_currency(appointment.per_minute_rate)
  end

  # formatted time 3:00 PM on Sunday, 1/1
  def time
    return "" unless appointment.time.present?
    day = if (appointment.time.to_date == Date.today) 
      'Today'
    elsif (appointment.time.to_date == Date.tomorrow) 
      'Tomorrow'
    else
      appointment.time.to_time.strftime("%A")
    end
    appointment.time.to_time.strftime("%-l:%M%P %Z #{day}, %-m/%-e")
  end

end