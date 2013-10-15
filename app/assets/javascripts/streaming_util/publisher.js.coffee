class Publisher
  constructor: (channel) ->
    @stateOn = true
    @faye = window.fayeClient
    @channel = channel
    @subscription = @faye.subscribe @channel, (message) ->
  
  broadcast: (message) ->
    @faye.publish(@channel, message) if @stateOn

  stop: ->
    @stateOn = false
    @faye.unsubscribe(@channel)

  on: ->
    @stateOn = true

  isOn: ->
    @stateOn

  register: (slide_id, callback) ->
    @stateOn = true
    $.post "/streaming/register",
      channel: @channel
      slide_id: slide_id
      (data) ->
        callback()

class MovePublisher extends Publisher
    constructor: (channel) ->
      super(channel)

    makeMessagePayload: (userName, pageNum) ->
      payload =
        messageType: 'move'
        messageOwner: userName
        messageExtra:
          pageNum: pageNum
      return payload

    move: (userName, pageNum) ->
      @broadcast(@makeMessagePayload(userName, pageNum))

window.MovePublisher = MovePublisher
window.Publisher = Publisher
