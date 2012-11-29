class ChangeLawyersIsApproved < ActiveRecord::Migration
  def up
    change_column :users, :is_approved, :boolean, :default => true
  end

  def down
    change_column :users, :is_approved, :boolean, :default => false
  end
end
