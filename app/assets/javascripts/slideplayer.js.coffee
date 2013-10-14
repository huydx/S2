class SlidePlayer
  PRELOAD_IMAGE_COUNT = 10

  constructor: (@slidePrefix, @slideSuffix, @totalPage) ->
    @currentPage = 1
    @progress = $(".player_progress")
    @images_loaded = (false for i in [0..@totalPage])

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
      if @images_loaded[index]
        percent = Math.round(index  * 100 / @totalPage)
        @progress.css("width", "#{percent}%")
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

  next: () ->
    @gotoPage(@currentPage + 1)

  fullScreen: (element_name) ->
    element = $(element_name)[0]
    if element.requestFullScreen
      element.requestFullScreen()
    else if element.mozRequestFullScreen
      element.mozRequestFullScreen()
    else if element.webkitRequestFullScreen
      element.webkitRequestFullScreen()

class StreamingController
  constructor: (streaming_button_name, drawing_button_name, clear_button_name) ->
    @statusDisplay = false
    @controllerElem = $(".slide_controller")
    @controllerDispButton = $("#slide_controller_display")
    @loading = $("#loading")

    slideInfo = $("#slide_info")
    @slideId = slideInfo.data("id")

    streaming_info = $("#streaming_info")
    @event_server_url = streaming_info.data("eventserver")
    @streaming_host = streaming_info.data("hostname")
    @channel = streaming_info.data("channel")

    @streaming_button = $(streaming_button_name)
    @drawing_button = $(drawing_button_name)
    @clear_button = $(clear_button_name)
    @controllerElem.animate {
        bottom: "-100"
      }, 1000

  binding: ->
    @controllerDispButton.on "click", (e) =>
      if (@statusDisplay)
        controllerTranslation = "-100"
        dispButtonTranslation = "0"
      else
        controllerTranslation = "0"
        dispButtonTranslation = "+100"
      
      @statusDisplay = !@statusDisplay
      @controllerElem.animate {
        bottom: controllerTranslation
      }, 1000
      @controllerDispButton.animate {
        bottom: dispButtonTranslation
      }, 1000
      e.preventDefault()

    @streaming_button.on "click", (e) =>
      @loading.show()
      window.fayeClient = new Faye.Client(@event_server_url)
      window.publisher = new MovePublisher(@channel)
      window.publisher.register @slideId, () =>
        @loading.hide()

      window.receiver = new QuestionReceiver(@channel)
      e.preventDefault()

    @drawing_button.on "click", (e) =>
      window.drawer = new Drawer("#drawing_canvas", @streaming_host, @channel)
      window.drawer.binding()
      e.preventDefault()

    @clear_button.on "click", (e) =>
      window.drawer.clear()
      e.preventDefault()

window.StreamingController = StreamingController
window.SlidePlayer = SlidePlayer
