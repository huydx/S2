class PageLikeController < ApplicationController
  protect_from_forgery except: [:create]
  layout false

  def index
    page_like = PageLike.new(params.merge({"userName" => username}))
    render json: page_like.to_json 
  end

  def create
    page_like = PageLike.new(params.merge({"userName" => username}))
    if page_like.able_to_save?
      page_like.like if params["likeAction"]
      page_like.dislike if params["dislikeAction"]

      channel = make_channel(params['slideId'] || params['slide_id'])
      notify_payload = make_notify_payload({has_like: true})
      broadcast(channel, notify_payload)
      render nothing: true, status: 200
    else
      render nothing: true, status: 422
    end
  rescue Exception=>e
    render nothing: true, status: 500
  end
end
