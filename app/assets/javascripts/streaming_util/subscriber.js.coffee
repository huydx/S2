class Subscriber
  constructor: (channel) ->
    @stateOn = true
    @faye = window.fayeClient
    @channel = channel

  stop: ->
    @stateOn = false
    @faye.unsubscribe(@channel)

  on: ->
    @stateOn = true

  isOn: ->
    @stateOn

window.Subscriber = Subscriber
