class CreateOfferingTypes < ActiveRecord::Migration
  def change
    create_table :offering_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
