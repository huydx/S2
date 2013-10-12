class Publisher
  constructor: (event_server_url, channel) ->
    @faye = new Faye.Client(event_server_url)
    @channel = channel
    @subscription = @faye.subscribe channel, (message) ->
  
  broadcast: (message) ->
    @faye.publish(@channel, message)

  stop: ->
    @subscription.cancel()

window.Publisher = Publisher
