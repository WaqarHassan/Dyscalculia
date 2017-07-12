class UserOverviewController < ApplicationController
  def index
    user = User.find(current_user)
    @tests = user.user_tests
    @first_name = user.first_name
    @last_name = user.last_name
  end

  def show_details
    @user = current_user
    @editable = true
  end

  def show_details_admin
    @user = current_user
    @editable = true
    render 'user_overview/show_details', layout: "admin"
  end

  def edit_details
    render 'devise/registrations/edit'
  end
end
