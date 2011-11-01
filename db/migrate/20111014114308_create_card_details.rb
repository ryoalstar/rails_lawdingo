class CreateCardDetails < ActiveRecord::Migration
  def change
    create_table :card_details do |t|
      t.integer :user_id
      t.string :first_name
      t.string :last_name
      t.string :street_address
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :country
      t.string :card_type
      t.string :card_number
      t.string :expire_month
      t.string :expire_year
      t.string :card_verification
      t.timestamps
    end
  end
end
