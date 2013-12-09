class @AudioReceptor
  constructor: (channel, server_url) ->
    id = Math.floor Math.random() * 1000
    @peer = new Peer id,
      "host": server_url
      "port": 9000
    @stateOn = true
    @$audio = $("#audio")

    @peer.connect channel.replace("/", "")
    @peer.on "call", @recept

  recept: (conn) =>
    conn.on "stream", @output_audio
    conn.answer()

  output_audio: (stream) =>
    @$audio.attr "src", URL.createObjectURL(stream)

  stop: ->
    @stateOn = false
    @peer.destroy()
