class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
    
  def current_user
    @user ||= User.find_by_id(session[:user_id])
  end
  helper_method :current_user

  def require_user
    if current_user.nil?
      flash[:notice] = "Woah, nelly -- not so fast. You have to be logged in."
      session[:user_requested_url] = request.url unless request.xhr?
      session.delete(:user_id)
      redirect_to root_path and return false
    end
  end
end
