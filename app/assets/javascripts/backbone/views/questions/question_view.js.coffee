S2.Views.Questions ||= {}

class S2.Views.Questions.QuestionView extends Backbone.View
  initialize: ->
    @slideId = $("#slide_info").data("id")

  template: JST["backbone/templates/questions/question"]
  
  className: "question"
  
  events:
    "click .vote-up" : "voteUp"
    "click .vote-down" : "voteDown"

  render: ->
    $(@el).html(@template(@model.toJSON()))
    return this

  voteUp: (e)=>
    that = this
    $.ajax({
        type: "POST"
        url: "/question/vote"
        data:
          type: "up"
          question_id: @model.get("questionId"),
          slide_id : @slideId
      }).done((msg) ->
        $(that.el).find(".vote-count-post").html(msg.score)
        $(that.el).find(".vote-up").removeClass("vote-up-off")
        $(that.el).find(".vote-up").addClass("vote-up-on")
      )
    e.preventDefault()

  voteDown: (e)=>
    that = this
    $.ajax({
        type: "POST"
        url: "/question/vote"
        data:
          type: "down"
          question_id: @model.get("questionId"),
          slide_id : @slideId
      }).done((msg) ->
        $(that.el).find(".vote-count-post").html(msg.score)
        $(that.el).find(".vote-down").removeClass("vote-down-off")
        $(that.el).find(".vote-down").addClass("vote-down-on")
      )
    e.preventDefault()
