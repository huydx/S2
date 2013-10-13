# encoding: UTF-8

class SessionsController < Devise::SessionsController
  def new
    super
  end

  def create
    begin
      slide_share = SlideShare::Base.new(
        api_key: ENV['API_KEY'],
        shared_secret: ENV['SHARED_SECRET'])
      slide_share.leads.find_campaigns_by_user params[:user][:username], params[:user][:password]

      if User.find_by username: params[:user][:username]
        self.resource = warden.authenticate!(auth_options)
        set_flash_message(:notice, :signed_in) if is_navigational_format?

        sign_in(resource_name, resource)
        respond_with resource, location: after_sign_in_path_for(resource)
      else
        user = User.create(
          username: params[:user][:username],
          password: params[:user][:password])
        sign_in user
        respond_with user, location: after_sign_in_path_for(user)
      end
    rescue
      #TODO Use i18n
      flash.now[:notice] = "ユーザ名とパスワードが間違っています。
        SlideShareのアカウントでログインしてください。"
      self.resource = User.new
      render action: :new
    end
  end
end
