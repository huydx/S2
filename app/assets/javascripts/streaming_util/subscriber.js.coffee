class Subscriber
  constructor: (channel) ->
    @binding_events = []
    @stateOn = true
    @faye = window.fayeClient
    @channel = channel
    @faye.subscribe @channel, (message) =>
      switch message.messageType
        when "move"
          @triggerEvent "gotoPage", message.messageExtra.pageNum

  stop: ->
    @stateOn = false
    @faye.unsubscribe(@channel)

  on: ->
    @stateOn = true

  isOn: ->
    @stateOn

  triggerEvent: (trigger_event_name, pageNum) ->
    @binding_events.forEach (event, i) ->
      if trigger_event_name == event.name
        event.callback pageNum

  onEvent: (event, callback) =>
    @binding_events.push
      name:event
      callback: callback

window.Subscriber = Subscriber
