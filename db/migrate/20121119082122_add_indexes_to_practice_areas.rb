class AddIndexesToPracticeAreas < ActiveRecord::Migration
  def change
    add_index :practice_areas, :name
    add_index :practice_areas, :parent_id
    add_index :practice_areas, :created_at
    add_index :practice_areas, :is_national
  end
end
