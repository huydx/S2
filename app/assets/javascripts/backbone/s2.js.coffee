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
