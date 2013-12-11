class S2.Models.Question extends Backbone.Model
  urlRoot: '/question'

  defaults:
    content: ""
    voteNum: 0
    slideId: null
    alreadyVoted: null

class S2.Collections.QuestionsCollection extends Backbone.Collection
  model: S2.Models.Question
  url: ->
    slideInfo = $("#slide_info")
    "/#{slideInfo.data("id")}/question/all"
