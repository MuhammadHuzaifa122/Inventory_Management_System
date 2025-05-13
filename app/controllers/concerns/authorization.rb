module Authorization
  extend ActiveSupport::Concern

  included do
    before_action :authorize_admin!, only: [ :destroy, :new, :create ]
  end

  private

  def authorize_admin!
    redirect_to root_path, alert: "Not authorized" unless current_user.admin?
  end
end
