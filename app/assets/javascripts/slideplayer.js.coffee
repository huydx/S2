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

window.SlidePlayer = SlidePlayer
