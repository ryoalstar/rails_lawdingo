class ChangePracticeAreasIsNational < ActiveRecord::Migration
  def up
    change_column :practice_areas, :is_national, :boolean, :default => 0
    PracticeArea.update_all("is_national = 0", ["is_national IS NULL"])
  end

  def down
    change_column :practice_areas, :is_national, :boolean
  end
end
