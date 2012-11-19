class AddIndexesToBarMemberships < ActiveRecord::Migration
  def change
    add_index :bar_memberships, :lawyer_id
    add_index :bar_memberships, :bar_id
    add_index :bar_memberships, :state_id
    add_index :bar_memberships, :created_at
  end
end
