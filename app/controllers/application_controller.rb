class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from AbstractController::ActionNotFound, with: :error_404
  rescue_from SlideShare::ServiceError, with: :error_404

  def after_sign_in_path_for resource
    user_path resource
  end
  private
  def error_404
    respond_to do |format|
      format.html { render :error_404, layout: 'application', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end
end
