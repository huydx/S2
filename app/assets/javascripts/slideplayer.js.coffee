class SlidePlayer
  PRELOAD_IMAGE_COUNT = 10

  constructor: (@slidePrefix, @slideSuffix, @totalPage) ->
    @currentPage = 1
    @$progress = $(".player_progress")
    @images_loaded = (false for i in [0..@totalPage])
    $(".next").on "click", (e) =>
      @next()
      e.preventDefault()

    $(".prev").on "click", (e) =>
      @prev()
      e.preventDefault()

    $("#fullscreen_btn").on "click", (e) =>
      @fullScreen("#player_container")

    $(document).keydown (e) =>
      if e.keyCode is 37 #left
        @prev()
      else if e.keyCode is 39 #right
        @next()

  loadImage: (index) ->
    if index > @totalPage
      return
    unless @images_loaded[index]
      that = this
      image = new Image
      image.onload = ->
        that.images_loaded[index] = true
      image.src = "http://#{@slidePrefix}#{index}#{@slideSuffix}"

  currentPage: ->
    @currentPage

  preload: ->
    for i in [1..PRELOAD_IMAGE_COUNT]
      @loadImage(i)

  gotoPage: (index) ->
    if index >= 1 and index <= @totalPage
      #re-render PageLike Bar
      if window.pageLike
        window.pageLike.clear()
        window.pageLike.fetch()

      if @images_loaded[index]
        percent = Math.round(index  * 100 / @totalPage)
        @$progress.css("width", "#{percent}%")
        @currentPage = index
        $("#current_slide").attr("src", "http://#{@slidePrefix}#{index}#{@slideSuffix}")
        for i in [1..index + PRELOAD_IMAGE_COUNT]
          @loadImage(i)
      

  isImgloaded: (index) ->
    if @images_loaded?
      return @images_loaded[index]
    return false

  prev: () ->
    @gotoPage(@currentPage - 1)
    window.publisher.move("", @currentPage) if window.publisher
    if window.drawer
      window.drawer.saveState(@currentPage+1)
      window.drawer.clearScreen()
      window.drawer.restoreState(@currentPage)

  next: () ->
    @gotoPage(@currentPage + 1)
    window.publisher.move("", @currentPage) if window.publisher
    if window.drawer
      window.drawer.saveState(@currentPage-1)
      window.drawer.clearScreen()
      window.drawer.restoreState(@currentPage)

  fullScreen: (element_name) ->
    element = $(element_name)[0]
    if element.requestFullScreen
      element.requestFullScreen()
    else if element.mozRequestFullScreen
      element.mozRequestFullScreen()
    else if element.webkitRequestFullScreen
      element.webkitRequestFullScreen()

class StreamingController
  constructor: () ->
    @statusDisplay = false
    @$controllerElem = $(".slide_controller")
    @$controllerDispButton = $("#slide_controller_display")
    @$loading = $("#loading")

    slideInfo = $("#slide_info")
    @slideId = slideInfo.data("id")

    streaming_info = $("#streaming_info")
    @event_server_url = streaming_info.data("eventserver")
    @streaming_host = streaming_info.data("hostname")
    @server_ip = streaming_info.data("serverip")
    @channel = streaming_info.data("channel")

    streaming_button_name = ".streaming_button"
    audio_transmit_button_name = ".audio_transmit_button"
    audio_recept_button_name = ".audio_recept_button"
    subscribe_button_name = ".subscribe_button"
    drawing_button_name = ".drawing_button"
    clear_button_name = ".clear_button"
    ask_question = ".ask_question"

    @streaming_button = $(streaming_button_name)
    @$audio_transmit_button = $(audio_transmit_button_name)
    @$audio_recept_button = $(audio_recept_button_name)
    @$subscribe_button = $(subscribe_button_name)
    @drawing_button = $(drawing_button_name)
    @clear_button = $(clear_button_name)
    @ask_question_button = $(ask_question)

    @streaming_button_pressed = false
    @subscribe_button_pressed = false
    @drawing_button_pressed = false
    @clear_button_pressed = false

    @$controllerElem.animate {
        bottom: "-100"
      }, 500

  binding: ->
    @$controllerDispButton.on "click", (e) =>
      if (@statusDisplay)
        controllerTranslation = "-100"
      else
        controllerTranslation = "0"

      @statusDisplay = !@statusDisplay
      @$controllerElem.animate {
        bottom: controllerTranslation
      }, 500
      e.preventDefault()

    @streaming_button.on "click", (e) =>
      if @streaming_button_pressed
        @streaming_button.find(".pressed_state").hide()
        @streaming_button.find(".normal_state").show()
        window.publisher.stop() if window.publisher
      else
        @streaming_button.find(".pressed_state").show()
        @streaming_button.find(".normal_state").hide()
        @$loading.show()
        window.fayeClient = new Faye.Client(@event_server_url)
        window.publisher = new MovePublisher(@channel)
        window.publisher.register @slideId, () =>
          @$loading.hide()

        window.receiver = new QuestionReceiver(@channel)
        e.preventDefault()

      @streaming_button_pressed = !@streaming_button_pressed

    @$subscribe_button.on "click", (e) =>
      e.preventDefault()

      if @subscribe_button_pressed
        @$subscribe_button.find(".pressed_state").hide()
        @$subscribe_button.find(".normal_state").show()
        window.subscriber.stop() if window.subscriber
      else
        @$subscribe_button.find(".pressed_state").show()
        @$subscribe_button.find(".normal_state").hide()
        window.fayeClient = new Faye.Client @event_server_url
        window.subscriber = new Subscriber @channel
        window.subscriber.onEvent "gotoPage", (pageNum) =>
          window.player.gotoPage pageNum if pageNum

      @subscribe_button_pressed = !@subscribe_button_pressed

    @drawing_button.on "click", (e) =>
      if @drawing_button_pressed
        @drawing_button.find(".pressed_state").hide()
        @drawing_button.find(".normal_state").show()
        window.drawer.off() if window.drawer
      else
        @drawing_button.find(".pressed_state").show()
        @drawing_button.find(".normal_state").hide()
        unless window.drawer and window.drawer.isOn()
          window.drawer = new Drawer("#drawing_canvas", @streaming_host, @channel)
        window.drawer.binding()
        e.preventDefault()

      @drawing_button_pressed = !@drawing_button_pressed

    @clear_button.on "click", (e) =>
      window.drawer.clear() if window.drawer
      e.preventDefault()

    @ask_question_button.on "click", (e) =>
      pageNum = window.player.currentPage #TODO: when deal with module which need to ref to each other,what is the best design
      $.colorbox({href: "/question/ask_page?slideId=" + @slideId + "&slidePageNum=" + pageNum})
      e.preventDefault()

    @$audio_transmit_button.on "click", (e) =>
      e.preventDefault()

      if window.peer && window.peer.stateOn
        window.peer.stop()
        @$audio_transmit_button.find(".pressed_state").hide()
        @$audio_transmit_button.find(".normal_state").show()
      else
        window.peer = new AudioTransmitter @channel, @server_ip
        @$audio_transmit_button.find(".pressed_state").show()
        @$audio_transmit_button.find(".normal_state").hide()

    @$audio_recept_button.on "click", (e) =>
      e.preventDefault()

      if window.peer && window.peer.stateOn
        window.peer.stop()
        @$audio_recept_button.find(".pressed_state").hide()
        @$audio_recept_button.find(".normal_state").show()
      else
        window.peer = new AudioReceptor @channel, @server_ip
        @$audio_recept_button.find(".pressed_state").show()
        @$audio_recept_button.find(".normal_state").hide()

window.StreamingController = StreamingController
window.SlidePlayer = SlidePlayer
