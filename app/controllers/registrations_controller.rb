class RegistrationsController < Devise::RegistrationsController
  def new
    super
  end

  def create
   build_resource(sign_up_params)
   begin
     SlideShare::Base.new(
       api_key: ENV['API_KEY'],
       shared_secret: ENV['SHARED_SECRET']
     ).leads.find_campaigns_by_user("#{sign_up_params["username"]}",
       "#{sign_up_params["password"]}")
     if resource.save!
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        if is_navigational_format?
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}"
        end
        expire_session_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
     end
   rescue
     build_resource(sign_up_params)
     clean_up_passwords resource
     render action: :new
   end
  end
end
