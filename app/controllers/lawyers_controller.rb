class LawyersController < ApplicationController

  def new
    @lawyer = Lawyer.new
    @states = State.all
    @states.count.times do
      @lawyer.bar_memberships.build
    end
  end

  def create
    @lawyer = Lawyer.new(params[:lawyer])
    if @lawyer.save
      self.log_in_user!(@lawyer)
      # deliver our signup notification
      UserMailer.notify_lawyer_application(@lawyer).deliver
      # redirect to the newly created account
      return redirect_to(user_path(@lawyer))
    else
      @states = State.all
      return render(:action => :new)
    end
  end

end