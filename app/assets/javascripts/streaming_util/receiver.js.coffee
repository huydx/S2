class Receiver
  constructor: (channel) ->
    @faye = window.fayeClient
    @channel = channel

  messageCallback: (message) ->
  
  stop: ->
    @subscription.cancel()

class QuestionReceiver extends Receiver
    constructor: (channel) ->
      super(channel)
      @subscription = @faye.subscribe channel, (message) =>
        @messageCallback(message)

    messageCallback: (message) ->
      super(message)
      if message.messageType is "question"
        @execute(message)

    execute: (message) ->
      extra = message.messageExtra
      owner = message.messageOwner

      questionContent = extra.content
      questionTitle = extra.title
      $.gritter.add
        title: questionTitle
        text: questionContent
        sticky: true

window.Receiver = Receiver
window.QuestionReceiver = QuestionReceiver
