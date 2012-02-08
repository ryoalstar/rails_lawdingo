class AttorneysController < ApplicationController
  def show
    @attorney = Lawyer.find(params[:id])
  end
end

