class UserMailer < ActionMailer::Base
  default :from => "lawdingo@gmail.com",
          :bcc => "offline@lawdingo.com"

  def schedule_session_email(user, lemail, msg)
    @user = user
    @msg = msg
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/logo.png")
    mail(
      :from => user.email,
      :to => lemail,
      :return_path => user.email,
      :subject => "Lawdingo appointment request while you were offline"
    )
  end

  def notify_lawyer_application(user)
    @lawyer = user
    mail(
      :to => "nikhil.nirmel@gmail.com",
      :subject => "New lawyer applied"
    )
  end

  def password_reset(user)
    attachments.inline['logo.png'] = File.read("#{Rails.root}/app/assets/images/logo.png")
    @user = user
    mail :to => user.email, :subject => "Password Reset"
  end
end

