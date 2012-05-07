class CreateDailyHours < ActiveRecord::Migration
  def up
    create_table(:daily_hours) do |t|
      t.integer(:lawyer_id)
      t.integer(:wday)
      t.integer(:start_time)
      t.integer(:end_time)
    end
  end

  def down
    drop_table(:daily_hours)
  end
end
