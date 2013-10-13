class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from AbstractController::ActionNotFound, with: :error_404
  rescue_from SlideShare::ServiceError, with: :error_404
  rescue_from ActionController::RoutingError, with: :error_403

  def after_sign_in_path_for resource
    user_path resource
  end

  def after_sign_out_path_for resource
    root_path
  end

  private
  def require_user
    raise ActionController::RoutingError.new('Forbidden') unless current_user
  end

  def error_404
    respond_to do |format|
      format.html { render :error_404, layout: 'application', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def error_403
    respond_to do |format|
      format.html { render :error_403, layout: 'application', status: 403 }
      format.all { render nothing: true, status: 403 }
    end
  end

end
