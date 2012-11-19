class AddDirectoryOnlyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :directory_only, :boolean, :default => false
  end
end
