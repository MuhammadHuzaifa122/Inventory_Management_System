class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
  redirect_to root_path, alert: "Access denied!"
  end

  allow_browser versions: :modern
end
