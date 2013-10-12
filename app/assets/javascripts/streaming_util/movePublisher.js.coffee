$ ->
  class MovePublisher extends Publisher
    constructor: (event_server_url, channel) ->
      super(event_server_url, channel)

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
