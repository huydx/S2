class Publisher
  constructor: (channel) ->
    @faye = window.fayeClient
    @channel = channel
    @subscription = @faye.subscribe channel, (message) ->
  
  broadcast: (message) ->
    @faye.publish(@channel, message)

  stop: ->
    @subscription.cancel()

  register: (slide_id, callback) ->
    $.post "/streaming/register",
      channel: @channel
      slide_id: slide_id
      (data) ->
        callback()

window.Publisher = Publisher
