class AddPracticeAreaToAppointments < ActiveRecord::Migration
  def up
    change_table :appointments  do |t|
      t.references :practice_area, :null => true, :after => :appointment_type
    end
    add_index :appointments, :practice_area_id
  end
  def down
    remove_column :appointments, :practice_area_id
  end
end

