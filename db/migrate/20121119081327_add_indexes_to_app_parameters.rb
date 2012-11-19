class AddIndexesToAppParameters < ActiveRecord::Migration
  def change
    add_index :app_parameters, :name
    add_index :app_parameters, :created_at
  end
end
