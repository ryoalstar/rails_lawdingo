class LawyersController < ApplicationController

  def index
    @users  = User.get_lawyers
  end

  def new
    @lawyer = Lawyer.new
    @states = State.all
    @states.count.times do
      @lawyer.bar_memberships.build
    end
  end

  def create
    @lawyer = Lawyer.new(params[:lawyer])
    @states = State.all
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

end