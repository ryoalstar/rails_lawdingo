object @appointment
attributes :appointment_type, :lawyer_name, :contact_number, :time
# display errors where appropriate
node :errors, :if => lambda{|a| a.errors.present?} do
  @appointment.errors
end