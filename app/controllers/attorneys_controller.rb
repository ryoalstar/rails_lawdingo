class AttorneysController < ApplicationController
  before_filter :check_approval, only: :show

  def show
    @attorney = Lawyer.find(params[:id])
  end

  private

    def check_approval
      redirect_to lawyers_path unless Lawyer.find(params[:id]).is_approved
    end
end

