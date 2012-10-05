class AddNonUsaOrUkState < ActiveRecord::Migration
  def up
    State.create(:name=>'Non-US/UK', :abbreviation=>'Non-US/UK')
  end

  def down
    State.find_by_name('Non-US/UK').delete
  end
end
