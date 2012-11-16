class AddPublishedToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :published, :boolean, :default=>false
  end
end
