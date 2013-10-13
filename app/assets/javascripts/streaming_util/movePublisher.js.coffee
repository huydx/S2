$ ->
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
