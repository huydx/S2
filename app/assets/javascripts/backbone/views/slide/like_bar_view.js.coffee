S2.Views.Slide ||= {}

class S2.Views.Slide.LikeBarView extends Backbone.View
  template: JST["backbone/templates/slide/like_bar"]

  el: "#like-bar-view"

  initialize: ->
    @options.pageLike.on('change', @render)

  render: =>
    @$el.html(@template(like: @options.pageLike.toJSON()))
