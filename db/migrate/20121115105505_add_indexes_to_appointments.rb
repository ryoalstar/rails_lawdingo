class AddIndexesToAppointments < ActiveRecord::Migration
  def change
    add_index :appointments, :lawyer_id
    add_index :appointments, :time
    add_index :appointments, :appointment_type
    add_index :appointments, :created_at
    add_index :appointments, :client_id
  end
end
