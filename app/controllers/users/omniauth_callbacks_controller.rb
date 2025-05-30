class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    handle_omniauth("GitHub")
  end

  def google_oauth2
    handle_omniauth("Google")
  end

  private

  def handle_omniauth(kind)
    auth = request.env["omniauth.auth"]
    Rails.logger.debug "OMNIAUTH DEBUG: #{auth.inspect}"

    if auth.nil?
      flash[:alert] = "#{kind} authentication failed: no auth data received"
      redirect_to new_user_session_path and return
    end

    @user = User.from_omniauth(auth)

    if @user.nil?
      flash[:alert] = "Your account has been deleted. Please sign up again."
      redirect_to new_user_registration_url and return
    end

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: kind) if is_navigational_format?
    else
      session["devise.#{kind.downcase}_data"] = auth
      redirect_to new_user_registration_url
    end
  end
end
