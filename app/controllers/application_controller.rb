class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from AbstractController::ActionNotFound, with: :error_404
  rescue_from SlideShare::ServiceError, with: :error_404
  rescue_from ActionController::RoutingError, with: :error_403

  def after_sign_in_path_for resource
    home_index_path
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
  
  def set_up_api
    @api_instance = SlideShare::Base.new(
      api_key: ENV['API_KEY'], 
      shared_secret: ENV['SHARED_SECRET']
    )
  end

  def username
    current_user.nil? ? (params["user_name"] || "") : current_user.username
  end

  def broadcast(channel, payload)
    mes = {:channel => channel, data: payload}
    uri = URI.parse(event_server)
    Net::HTTP.post_form(uri, message: mes.to_json)
  end

  def event_server
    "#{ENV['EVENT_SERVER']}faye"
  end

  def make_channel(slide_id)
    host_name = $redis.get("streaming:#{slide_id}")
    host_name[0] == "/" ? host_name : "/#{host_name}"
  end

  def make_notify_payload(options={})
    {'messageType' => 'notify',
     'messageOwner' => username,
     'messageExtra' => options}
  end
end
