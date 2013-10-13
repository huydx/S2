module StreamingHelper
  def title(slide)
    raw(slide[:info]["Slideshow"]["Title"])
  end
  
  def slide_id(slide)
    slide[:info]["Slideshow"]["ID"]
  end

  def first_page(slide)
    "http://#{slide[:image_info][:prefix]}1#{slide[:image_info][:suffix]}"
  end

  def pages(slide)
    slide[:image_info][:total_slides]
  end

  def suffix(slide)
    slide[:image_info][:suffix]
  end

  def prefix(slide)
    slide[:image_info][:prefix]
  end

  def event_server_url
    "#{ENV["EVENT_SERVER"]}faye"
  end

  def event_server_js_file
    "#{ENV["EVENT_SERVER"]}faye.js"
  end

  def current_user_name 
    current_user.username
  end

  def channel
    current_user_name
  end
end
