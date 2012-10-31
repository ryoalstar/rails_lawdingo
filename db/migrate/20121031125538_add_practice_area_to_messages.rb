class AddPracticeAreaToMessages < ActiveRecord::Migration
  def up
    change_table :messages  do |t|
      t.references :practice_area, :null => true
    end
  end

  def down
    remove_column :messages, :practice_area_id
  end
end
