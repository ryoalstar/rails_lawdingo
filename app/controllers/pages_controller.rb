class PagesController < ApplicationController

  def show    
    begin
      @page = Page.find_by_name params[:name]
    rescue
      @page = nil
    end
    unless @page
      render :template =>"/shared/no_page" and return
    end

  end
  
end
