class AddIndexesToOfferings < ActiveRecord::Migration
  def change
    add_index :offerings, :name
    add_index :offerings, :created_at
    add_index :offerings, :user_id
    add_index :offerings, :practice_area_id
  end
end
