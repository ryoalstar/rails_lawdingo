class CreateCalls < ActiveRecord::Migration
  def change
    create_table :calls do |t|
      t.references :client
      t.integer :lawyer_id
      t.string :sid
      t.string :status

      t.timestamps
    end
  end
end

