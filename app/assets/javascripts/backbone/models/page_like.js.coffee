class S2.Models.PageLike extends Backbone.Model
  urlRoot: ->
    return "/page_like?slideId=#{@getSlideId()}&pageNum=#{@getPageNum()}"
  
  getSlideId: ->
    slideInfo = $("#slide_info")
    return slideInfo.data("id")

  getPageNum: ->
    if window.player?
      page = window.player.currentPage
    else
      page = 1
    return page

  defaults:
    likePercent: 50
    likeNum: 0
    dislikePercent: 50
    dislikeNum: 0
    slideId: null
    pageNum: null
    likeAction: null
    dislikeAction: null
