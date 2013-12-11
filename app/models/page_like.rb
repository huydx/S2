class PageLike
  #because there are many nested attributes
  #so that we can not use Redis::Objects
  attr_accessor :slide_id, :page_num, :user_name

  def initialize(params={})
    raise PageLikeBadParamsError unless (params["slideId"] && params["pageNum"])

    @slide_id = params["slideId"]
    @page_num = params["pageNum"]
    @user_name = params["userName"]
  end

  def like_num
    $redis.get like_key_name || 0
  end

  def dislike_num
    $redis.get dislike_key_name || 0
  end
  
  def increment_like_num
    $redis.incr like_key_name
  end

  def increment_dislike_num
    $redis.incr dislike_key_name
  end
  
  def liked_or_disliked_action
    $redis.set already_liked_or_disliked_key, 1
  end

  def able_to_save?
    !$redis.get already_liked_or_disliked_key
  end

  def like_percent
    like_num * 100 / (like_num + dislike_num) rescue 50
  end

  def dislike_percent
    dislike_num * 100 / (like_num + dislike_num) rescue 50
  end

  def to_json
    { likePercent: like_percent,
      likeNum: like_num,
      dislikePercent: dislike_percent,
      dislikeNum: dislike_num }.to_json
  end

  def like
    increment_like_num
    liked_or_disliked_action
  end

  def dislike
    increment_dislike_num
    liked_or_disliked_action
  end
private
  def like_key_name
    "like:#{@slide_id}:#{@page_num}"
  end

  def dislike_key_name
    "dislike:#{@slide_id}:#{@page_num}"
  end

  def already_liked_or_disliked_key
    "like_or_dislike:#{@slide_id}:#{@page_num}:#{@user_name}"
  end
end

class PageLikeBadParamsError < Exception; end 
