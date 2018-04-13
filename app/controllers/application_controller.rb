class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :role, :avatar, :description])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :role, :avatar, :description])
  end
end
