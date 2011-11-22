class UserMailer < ActionMailer::Base
  default :from => "lawdingo@gmail.com",
          :bcc => "offline@lawdingo.com"

  def schedule_session_email(user, lemail, msg)
    @user = user
    @msg = msg
    mail(
      :from => user.email,
      :to => lemail,
      :return_path => user.email,
      :subject => "Lawdingo appointment request while you were offline"
    )
  end
end

