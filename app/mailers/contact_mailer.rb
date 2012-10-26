class ContactMailer < ApplicationMailer

  default :from => "'Contact' <contact@lawdingo.com>"

  def contact_email(name, email, body)
    @name = name
    @email = email
    @body = body
    mail(
      :to => "nikhil.nirmel@gmail.com",
      :subject => "Message from contact form"
    )
  end
  
  def new_subscriber(email)

    @email = email
    mail(
      :to => "nikhil.nirmel@gmail.com",
      :subject => "New subscriber"
    )
  end
end