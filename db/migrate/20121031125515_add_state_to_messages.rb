class AddStateToMessages < ActiveRecord::Migration
  def up
    change_table :messages  do |t|
      t.references :state, :null => true
    end
  end

  def down
    remove_column :messages, :state_id
  end
end
