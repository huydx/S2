class HomeController < ApplicationController
  def index
    slide_share = SlideShare::Base.new(
       api_key: ENV['API_KEY'],
       shared_secret: ENV['SHARED_SECRET'])
    slide_share_obj = slide_share.slideshows.find_all_by_user current_user.username

    @slides = case slide_share_obj["User"]["Count"]
              when "0"
                []
              when "1"
                [slide_share_obj["User"]["Slideshow"]]
              else
                slide_share_obj["User"]["Slideshow"]
              end
  end
end
