class RegistrationsController < Devise::RegistrationsController

  private
  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :date_of_birth, :level_of_education, :postcode, :gender, :diagnosis, :employment_status)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password, :date_of_birth, :level_of_education, :postcode,:gender, :diagnosis, :employment_status)
  end

end
