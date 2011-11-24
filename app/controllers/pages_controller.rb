class PagesController < ApplicationController

  def show
    #begin
     # @page = Page.find_by_name params[:name]
    #rescue
     # @page = nil
    #end
    render "about"
    #unless @page
     # render :template =>"/shared/no_page" and return
    #end

  end

  def about_client
    render "about_attorneys"
  end

end

