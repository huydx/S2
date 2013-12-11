S2.Views.Slide ||= {}

class S2.Views.Slide.LikeButtonView extends Backbone.View
  template: JST["backbone/templates/slide/like_button"]
  
  events:
    "click .like-button" : "like"
    "click .dislike-button" : "dislike"

  el: "#like-button-view"

  initialize: ->
    @options.pageLike.on('change', @render)


  render: =>
    @$el.html(@template(like: @options.pageLike.toJSON()))

  like: (e)=>
    pageLike = @options.pageLike
    pageLike.set
      slideId: pageLike.getSlideId()
      pageNum: pageLike.getPageNum()
      likeAction: 1
    pageLike.save()

  dislike: (e)=>
    pageLike = @options.pageLike
    pageLike.set
      slideId: pageLike.getSlideId()
      pageNum: pageLike.getPageNum()
      dislikeAction: 1
    pageLike.save()
