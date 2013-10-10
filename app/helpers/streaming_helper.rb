module StreamingHelper
  def title(slide)
    raw(slide[:info]["Slideshow"]["Title"])
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
end
