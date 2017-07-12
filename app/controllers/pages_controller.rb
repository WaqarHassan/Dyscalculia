class PagesController < ApplicationController
  
  def home
    @current_nav_identifier = :home
  end
  
end