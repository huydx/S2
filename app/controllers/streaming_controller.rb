class StreamingController < ApplicationController
  before_action :set_up_api
  before_action :require_user

  def index
    slide_id = params[:id]
    @slide = @api_instance.slideshows.find(slide_id, detailed: true, with_image: true) 
  end

  def search
    channel = params[:channel] 
    message_content = 'params error' and message_type = 'error' unless channel
    
    channel_info = $redis.get(channel)
    message_content = 'channel not found' and message_type = 'error' unless channel_info
    
    return_hash = channel_info.nil? ? {message_type: message_type, message_content: message_content} : channel_info

    respond_to do |format|
      format.html { render json: return_hash }
      format.json { render json: return_hash }
    end
  end

  def register_channel
    channel = params[:channel]
    slide_id = params[:slide_id]

    render nothing: true, status: 500 and return unless channel && slide_id
    
    slide_info = @api_instance.slideshows.find(slide_id, detailed: true, with_image: true)
    save_slide_info = make_save_object(channel, slide_info)
    $redis.set(channel, save_slide_info)

    render nothing: true, status: 200
  end
  
  private
  def set_up_api
    @api_instance = SlideShare::Base.new(
      api_key: ENV['API_KEY'], 
      shared_secret: ENV['SHARED_SECRET']
    )
  end

  def make_save_object(channel, slide_info)
    general_info = slide_info[:info]["Slideshow"]
    image_info = slide_info[:image_info]
    
    {    
      channel: channel,
      slideId: general_info["ID"],
      title: general_info["Title"],
      thumbnailUrl: general_info["ThumbnailURL"],
      created: general_info["Created"],
      numViews: general_info["NumViews"],
      numDownloads: general_info["NumDownloads"],
      numFavorites: general_info["NumFavorites"],
      totalSlides: image_info[:total_slides],
      slideImageBaseurl: image_info[:prefix],
      slideImageBaseurlSuffix: image_info[:suffix],
    }

  end
end
