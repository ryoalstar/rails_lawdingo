class AddIndexesToUsers < ActiveRecord::Migration
  def change
    add_index :users, :email
    add_index :users, :is_online
    add_index :users, :is_busy
    add_index :users, :is_approved
    add_index :users, :created_at
    add_index :users, :bar_ids
    add_index :users, :peer_id
    add_index :users, :school_id
    add_index :users, :call_status
    add_index :users, :type
  end
end

