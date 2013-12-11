#= require_self
#= require_tree ./templates
#= require_tree ./models
#= require_tree ./views
#= require_tree ./routers

window.S2 =
  Models: {}
  Collections: {}
  Routers: {}
  Views: {}
  initialize: ->
    window.questionCollection = new S2.Collections.QuestionsCollection
    questionListView = new S2.Views.Questions.IndexView({questions: window.questionCollection})
    window.questionCollection.fetch()
    questionListView.render()
    
    window.pageLike = new S2.Models.PageLike
    likeBarView = new S2.Views.Slide.LikeBarView({pageLike: window.pageLike})
    likeButtonView = new S2.Views.Slide.LikeButtonView({pageLike: window.pageLike})

    window.pageLike.fetch()
    likeBarView.render()
    likeButtonView.render()
