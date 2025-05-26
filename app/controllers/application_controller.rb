class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "Access denied."
    redirect_to(request.referer || root_path)
  end

  # rescue_from CanCan::AccessDenied do |exception|
  # redirect_to root_path, alert: "Access denied!"
  # end

  allow_browser versions: :modern
end
