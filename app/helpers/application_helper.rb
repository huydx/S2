module ApplicationHelper
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

  def server_ip
    "#{ENV["SERVER_IP"]}"
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
    "/#{current_user_name}"
  end

  def host_name_by_slide(slide)
    $redis.get "streaming:#{slide_id(slide)}"
  end

  def channel_by_slide(slide)
    host_name = host_name_by_slide(slide)
    host_name[0] == "/" ? host_name : "/#{host_name}"
  end
end
