class ChangeDirectoryLawyers < ActiveRecord::Migration
  def up
    Lawyer.directory.update_all("is_available_by_phone = 1", ["phone IS NOT NULL"])
  end

  def down
  end
end
