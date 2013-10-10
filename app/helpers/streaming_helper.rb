module StreamingHelper
  def title(slide)
    raw(slide[:info]["Slideshow"]["Title"])
  end
  
  def first_page(slide)
    "http://#{slide[:image_info][:prefix]}1#{slide[:image_info][:suffix]}"
  end
end
