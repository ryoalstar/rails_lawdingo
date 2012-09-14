class SetupLawyersPaymentStatus < ActiveRecord::Migration
  def up
    Lawyer.find_each do |lawyer|
      lawyer.update_attribute(:payment_status, :free)
    end
  end

  def down
    Lawyer.find_each do |lawyer|
      lawyer.update_attribute(:payment_status, :unpaid)
    end
  end
end
