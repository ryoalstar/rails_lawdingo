module ApplicationHelper

  def is_self_login? user_id
    current_user.id == user_id
  end

  def is_admin_login?
    current_user.is_admin?
  end

  def access_to_everything? user_id
    is_self?(user_id) or is_admin_login?
  end

  def seconds_in_string num_of_seconds
    n_sec = num_of_seconds.to_i
    t_str = ""
    if n_sec < 60
      t_str = ["00", "00" , n_sec.to_s.rjust(2, "0")].join(":")
    elsif
      hours = n_sec / 3600
      rem   = n_sec % 3600
      min   = rem / 60
      rem   = rem % 60
      t_str = [ hours.to_s.rjust(2,"0"), min.to_s.rjust(2,"0"), rem.to_s.rjust(2,"0") ].join(":")
    end
    t_str
  end

end

