class AddLawyerMountlyFeeToAppParameters < ActiveRecord::Migration
  def up
    AppParameter.lawyer_mountly_fee= AppParameter::LAWYER_MOUNTLY_FEE_VALUE
  end

  def down
    param = AppParameter.find_by_name(AppParameter::LAWYER_MOUNTLY_FEE).delete
  end
end
