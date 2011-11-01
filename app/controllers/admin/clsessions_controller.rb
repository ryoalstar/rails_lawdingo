class Admin::ClsessionsController < ApplicationController

  before_filter :authenticate_admin

  def index
    @sessions = [] # recent sessions
  end

end
