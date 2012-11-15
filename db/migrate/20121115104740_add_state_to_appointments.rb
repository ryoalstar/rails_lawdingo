class AddStateToAppointments < ActiveRecord::Migration
  def up
    change_table :appointments  do |t|
      t.references :state, :null => true, :after => :practice_area_id
    end
    add_index :appointments, :state_id
  end
  def down
    remove_column :appointments, :state_id
  end
end
