class LawyersController < ApplicationController

  def new
    @lawyer = Lawyer.new
    setup_form
  end

  def create
    @lawyer = Lawyer.new(params[:lawyer])
    setup_form
    if @lawyer.save
      self.log_in_user!(@lawyer)
      # deliver our signup notification
      UserMailer.notify_lawyer_application(@lawyer).deliver
      # redirect to the subscription
      return redirect_to(subscribe_lawyer_path)
    else
      return render(:action => :new)
    end
  end

  def setup_form
    @states = State.all
    @states.count.times do
      @lawyer.bar_memberships.build
    end
  end  
end