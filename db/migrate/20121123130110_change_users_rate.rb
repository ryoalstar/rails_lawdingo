class ChangeUsersRate < ActiveRecord::Migration
  def up
    change_column :users, :rate, :decimal, :precision => 10, :scale => 2, :default => 0.0
  end

  def down
    change_column :users, :rate, :float, :default => 0.0
  end
end
