class AddIndexesToStates < ActiveRecord::Migration
  def change
    add_index :states, :name
    add_index :states, :abbreviation
  end
end
