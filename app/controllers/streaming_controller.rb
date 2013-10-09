class StreamingController < ApplicationController
  before_action :set_up_api

  def index
    slide_id = params[:id]
    slide = @api_instance.slideshows.find(slide_id, detailed: true) 
  end

  def set_up_api
    @api_instance = SlideShare::Base.new(api_key: ENV['API_KEY'], shared_secret: ENV['SHARED_SECRET'])
  end
end
