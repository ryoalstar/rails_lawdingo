class AddIndexesToDailyHours < ActiveRecord::Migration
  def change
    add_index :daily_hours, :lawyer_id
    add_index :daily_hours, :wday
    add_index :daily_hours, :start_time
    add_index :daily_hours, :end_time
  end
end
