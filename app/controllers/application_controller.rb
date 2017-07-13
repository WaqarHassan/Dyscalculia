class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include CanCan::ControllerAdditions
  protect_from_forgery with: :exception
  before_action :update_headers_to_disable_caching
  before_action :ie_warning
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  layout :layout_by_resource


  def method_missing(method)
    if method.to_s.starts_with? 'render_'
      error_code = method.to_s.partition('render_')[2].to_i
      if error_code.is_a? Integer
        render "errors/error_#{error_code}", :status => error_code
        return
      end
    end
    super
  end

  ## The following are used by our Responder service classes so we can access
  ## the instance variable for the current resource easily via a standard method
  def resource_name
    controller_name.demodulize.singularize
  end

  def current_resource
    instance_variable_get(:"@#{resource_name}")
  end

  def current_resource=(val)
    instance_variable_set(:"@#{resource_name}", val)
  end

  # Catch NotFound exceptions and handle them neatly, when URLs are mistyped or mislinked
  rescue_from ActiveRecord::RecordNotFound do
    render template: 'errors/error_404', status: 404
  end
  rescue_from CanCan::AccessDenied do
    render template: 'errors/error_403', status: 403
  end

  # IE over HTTPS will not download if browser caching is off, so allow browser caching when sending files
  def send_file(file, opts={})
    response.headers['Cache-Control'] = 'private, proxy-revalidate' # Still prevent proxy caching
    response.headers['Pragma'] = 'cache'
    response.headers['Expires'] = '0'
    super(file, opts)
  end

  private
    def update_headers_to_disable_caching
      response.headers['Cache-Control'] = 'no-cache, no-cache="set-cookie", no-store, private, proxy-revalidate'
      response.headers['Pragma'] = 'no-cache'
      response.headers['Expires'] = '-1'
    end

    def ie_warning
      return redirect_to(ie_warning_path) if request.user_agent.to_s =~ /MSIE [6-7]/ && request.user_agent.to_s !~ /Trident\/7.0/
    end
protected
     def configure_permitted_parameters
       # devise_parameter_sanitizer.for(:sign_up) { |u| u.permit()}
       # devise_parameter_sanitizer.for(:sign_in) { |u| u.permit()}
       devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :email, :password, :date_of_birth, :level_of_education, :postcode, :remember_me])
       devise_parameter_sanitizer.permit(:sign_in, keys: [:first_name, :last_name, :email, :password, :date_of_birth, :level_of_education, :postcode, :remember_me])

     end
	def layout_by_resource
    	if user_signed_in?
      	"application"
      # elsif admin_signed_in?
    	#   "admin_overview"
      else
      	"base"
    	end
  end
end
