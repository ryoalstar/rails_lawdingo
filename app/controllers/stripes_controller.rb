class StripesController < ApplicationController

	before_filter :authenticate
	before_filter :check_lawyer_access, :only => [:new, :create, :coupon_validate]
  before_filter :check_client_access, :only => [:subscribe_question, :subscribe_question_create]
  
	def new
		@lawyer.create_stripe_customer! unless @lawyer.stripe_customer_token
	end

	def create
		respond_to do |format|
			if @lawyer.subscribed? # && params[:coupon].empty?
				format.html { redirect_to user_offerings_path(@lawyer, :ft => true) } # , :error => "You are subscribed already!" }
        format.json { render json: @lawyer, status: :ok }
      elsif params[:card] && @lawyer.create_stripe_card(params[:card]) # && @lawyer.apply_coupon(params[:coupon]) # && @lawyer.subscribe! l
        format.html { redirect_to user_offerings_path(@lawyer, :ft => true) } #, :notice => "Thank you for subscribing!" }
        format.json { render json: @lawyer, status: :created, location: @lawyer } 
      elsif params[:coupon].present? && @lawyer.apply_coupon(params[:coupon])
        format.html { redirect_to user_offerings_path(@lawyer, :ft => true) } #, :notice => "Thank you for subscribing! Your coupon applied!" }
        format.json { render json: @lawyer, status: :ok, location: @lawyer } 
      else
        format.html { render action: "new", :error => "Error. Something wrong." }
        format.json { render json: @lawyer.errors, status: :unprocessable_entity }
      end
    end
	end

	def coupon_validate
		respond_to do |format|
			if @lawyer.coupon_valid?(params[:coupon], false)
				format.html { render :nothing => true }
        format.json { render json: {:result => true, :coupon => @lawyer.stripe_get_coupon(params[:coupon])}, status: :ok }
      else
				format.html { render :nothing => true }
        format.json { render json: {:result => false, :errors => @lawyer.errors}, status: :ok }
      end
    end
	end	
	
	def subscribe_question
    check_question_owner
	  @client.create_stripe_customer! unless @client.stripe_customer_token
	end
	
	def subscribe_question_create
	  check_question_owner
    respond_to do |format|
      if params[:card] && @client.create_stripe_card(params[:card]) && @client.subscribe!(@stripe_plan.id)
        format.html { redirect_to subscribe_question_create_success_path, :notice => "Thanks, you'll get an email when a lawyer responds to you. In the mean time, you may contact one of the relevant lawyers below to start a discussion." }
        format.json { render json: @client, status: :created, location: @client } 
      else
        format.html { render action: "subscribe_question", :notice => "Error. Something wrong." }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
	end

	private

	def check_lawyer_access
		redirect_to root_path, :status => :unauthorized unless current_user.is_lawyer?
		@lawyer = current_user
		@stripe_plan = Lawyer::get_stripe_plan
	end
	
	def check_question_owner
    @question = Question.find params[:question_id] || not_found
    redirect_to root_path, :status => :unauthorized unless @client.owner?(@question)
	end
	
  def subscribe_question_create_success_path
    path_hash = {}
    path_hash[:state] = State.name_for_url(@question.state_name)  if @question.state_name.present?
    path_hash[:practice_area] = PracticeArea.name_for_url(@question.practice_area) if @question.practice_area.present?
    filtered_path(path_hash)
  end	
  
  def check_client_access
    redirect_to root_path, :status => :unauthorized unless current_user.is_client?
    @client = current_user
    @stripe_plan = Client::get_stripe_plan '4'
    redirect_to lawyers_path, :notice => "You are subscribed already!" if @client.subscribed?(@stripe_plan.id)
  end

end
