class PagesController < ApplicationController

  def show
    #begin
     # @page = Page.find_by_name params[:name]
    #rescue
     # @page = nil
    #end
    @title = "About Lawdingo"
    render "about"
    #unless @page
     # render :template =>"/shared/no_page" and return
    #end

  end

  def about_client
    @title = "About Lawdingo"
    render "about_attorneys"
  end

  def terms_of_use
  end
  
  def markup
    render "markup", :layout => 'new_markup'
  end

  def lawyers
    render "lawyers", :layout => 'new_markup'
  end

  def profile
    render "profile", :layout => 'new_markup'
  end

end

