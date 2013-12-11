class Subscriber
  constructor: (channel) ->
    @drawer = new Drawer("#drawing_canvas", @streaming_host, @channel)
    @binding_events = []
    @current_page = 0
    @stateOn = true
    @faye = window.fayeClient
    @channel = channel
    @faye.subscribe @channel, (message) =>
      switch message.messageType
        when "move"
          pageNum = message.messageExtra.pageNum
          if @current_page - pageNum == 1
            @drawer.saveState(pageNum + 1)
          else
            @drawer.saveState(pageNum - 1)
          @drawer.clearScreen()
          @drawer.restoreState pageNum
          @triggerEvent "gotoPage", pageNum
          @current_page = pageNum
        when "draw"
          @draw message.messageExtra.pointSet
        when "question"
          @addQuestion(message.messageExtra)
        when "notify"
          @processNotification(message.messageExtra)

  stop: ->
    @stateOn = false
    @faye.unsubscribe(@channel)

  on: ->
    @stateOn = true

  isOn: ->
    @stateOn

  triggerEvent: (trigger_event_name, arg = null) ->
    @binding_events.forEach (event, i) ->
      if trigger_event_name == event.name
        event.callback arg

  onEvent: (event, callback) =>
    @binding_events.push
      name:event
      callback: callback

  draw: (pointSet) ->
    if pointSet
      queue = pointSet.split " "
      @drawer.draw (queue[1] * @drawer.canvasWidth), (@drawer.canvasHeight * (1- queue[0])), "dragstart"
      @drawer.draw (queue[3] * @drawer.canvasWidth), (@drawer.canvasHeight * (1 - queue[2])), "drag"
      @drawer.draw (queue[5] * @drawer.canvasWidth), (@drawer.canvasHeight * (1 - queue[4])), "drag"
      @drawer.draw (queue[7] * @drawer.canvasWidth), (@drawer.canvasHeight * (1 - queue[6])), "drag"
  
  addQuestion: (questionPayload) ->
    model = new S2.Models.Question(questionPayload)
    window.questionCollection.add(model)

  processNotification: (notification) ->
    if notification.has_vote
      @resetQuestionList()
    if notification.has_like
      @resetLikeBar()
  
  resetQuestionList: ->
    window.questionCollection.reset()
    window.questionCollection.fetch()

  resetLikeBar: ->
    window.pageLike.clear()
    window.pageLike.fetch()

window.Subscriber = Subscriber
