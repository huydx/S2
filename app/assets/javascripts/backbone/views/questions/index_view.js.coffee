S2.Views.Questions ||= {}

class S2.Views.Questions.IndexView extends Backbone.View
  template: JST["backbone/templates/questions/index"]

  el: "#questions-list"

  initialize: () ->
    @options.questions.bind('reset', @addAll)
    @options.questions.bind('add', @render)
    @options.questions.bind('change', @render)

  addAll: () =>
    @options.questions.each(@addOne)

  addOne: (question) =>
    view = new S2.Views.Questions.QuestionView({model : question})
    @$el.append(view.render().el)
  
  render: =>
    $(@el).html(@template(questions: @options.questions.toJSON() ))
    @addAll()

    return this
