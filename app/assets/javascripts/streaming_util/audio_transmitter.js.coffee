class @AudioTransmitter
  constructor: (channel, server_url) ->
    @peer = new Peer channel.replace("/", ""),
      "host": server_url
      "port": 9000
    @stateOn = true
    @peer.on "connection", @stransmit

    navigator.getMedia = navigator.getUserMedia || navigator.webkitGetUserMedia ||
          navigator.mozGetUserMedia || navigator.msGetUserMedia

    navigator.getMedia audio: true,
      (stream) =>
        @stream = stream

  stransmit: (conn) =>
    if @stateOn
      @peer.call conn.peer, @stream

  stop: ->
    @stateOn = false
    @peer.destroy()
    @stream.stop() if @stream
