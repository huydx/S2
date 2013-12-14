S2.Views.Questions ||= {}

class S2.Views.Questions.IndexView extends Backbone.View
  template: JST["backbone/templates/questions/index"]

  el: "#questions-list"

  initialize: () ->
    @options.questions.on('reset', @addAll)
    @options.questions.on('add', @render)
    @options.questions.on('change', @render)

  addAll: () =>
    @options.questions.each(@addOne)

  addOne: (question) =>
    view = new S2.Views.Questions.QuestionView({model : question})
    @$el.append(view.render().el)

  empty: =>
    @$el.html("")

  render: =>
    @$el.html(@template(questions: @options.questions.toJSON() ))
    @addAll()

    return this
