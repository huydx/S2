class S2.Routers.QuestionsRouter extends Backbone.Router
  initialize: (options) ->
    @questions = new S2.Collections.QuestionsCollection()
    @questions.reset options.questions

  routes:
    "index"    : "index"
    ":id"      : "show"
    ".*"        : "index"

  index: ->
    @view = new S2.Views.Questions.IndexView(questions: @questions)
    $("#questions").html(@view.render().el)

  show: (id) ->
    question = @questions.get(id)

    @view = new S2.Views.Questions.ShowView(model: question)
    $("#questions").html(@view.render().el)
