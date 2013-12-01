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
    @$el.html(@template(@model.toJSON()))
    return this

  voteUp: (e)=>
    $.ajax({
        type: "POST"
        url: "/question/vote"
        data:
          type: "up"
          question_id: @model.get("questionId"),
          slide_id : @slideId
      }).done((msg) =>
        @$(".vote-count-post").html(msg.score)
        @$(".vote-up").removeClass("vote-up-off")
        @$(".vote-up").addClass("vote-up-on")
      )
    e.preventDefault()

  voteDown: (e)=>
    $.ajax({
        type: "POST"
        url: "/question/vote"
        data:
          type: "down"
          question_id: @model.get("questionId"),
          slide_id : @slideId
      }).done((msg) =>
        @$(".vote-count-post").html(msg.score)
        @$(".vote-down").removeClass("vote-down-off")
        @$(".vote-down").addClass("vote-down-on")
      )
    e.preventDefault()
