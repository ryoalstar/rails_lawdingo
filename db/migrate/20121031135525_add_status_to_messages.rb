class AddStatusToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :status, :string, :default => Message::STATUSES[0]
  end
end
