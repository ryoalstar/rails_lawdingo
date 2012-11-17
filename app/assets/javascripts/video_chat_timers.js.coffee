videoChatTimers =
  timeElapsedCounter: 0
  paidTimeCounter: 0
  freeTimeCounter: 600 # 10 minutes for free, darling

  initialize: ->
    @conversationId = ($ "#video_chat").data "conversation-id"
    @lawyersWatching = ($ "#video_chat").data "lawyers-watching"
    @freeTimeCounter = 60 * parseInt(($ "#video_chat").data "free-consultation-duration")
    @startedBilling = false

    @timeElapsed.set(time: 1000, autostart: false)
    @freeTimeRemaining.set(time: 1000, autostart: false)
    @paidTimeElapsed.set(time: 1000, autostart: false)
    @chatStatusInspector.set(time: 1000, autostart: true)

    ($ ".video-chat-timers").show()

  chatStatusInspector: $.timer ->
    videoChatTimers.timeElapsed.play()

    if videoChatTimers.startedBilling is false
      videoChatTimers.freeTimeRemaining.play()
    else
      videoChatTimers.freeTimeRemaining.pause()
      videoChatTimers.paidTimeElapsed.play()
      ($ "#free_time_remaining_wrapper").hide()
      ($ "#paid_time_elapsed_wrapper").show()

  startBilling: ->
    $.ajax(
        url: "/conversations/#{videoChatTimers.conversationId}/start-billing",
        type: "post"
        success: (response) ->
          videoChatTimers.startedBilling = true
          console.log "Billing started for conversation ##{videoChatTimers.conversationId}."
      )

  timeElapsed: $.timer ->
    ++videoChatTimers.timeElapsedCounter

    seconds = videoChatTimers.timeElapsedCounter % 60
    minutes = parseInt(videoChatTimers.timeElapsedCounter / 60)
    secondsString = if seconds.toString().length > 1 then seconds.toString() else "0#{seconds.toString()}"
    minutesString = if minutes.toString().length > 1 then minutes.toString() else "0#{minutes.toString()}"

    ($ "#time_elapsed").html "#{minutesString}:#{secondsString}"

  freeTimeRemaining: $.timer ->
    --videoChatTimers.freeTimeCounter

    if videoChatTimers.freeTimeCounter <= 0
      videoChatTimers.startBilling()
    else
      seconds = videoChatTimers.freeTimeCounter % 60
      secondsString = if seconds.toString().length > 1 then seconds.toString() else "0#{seconds.toString()}"
      minutes = parseInt(videoChatTimers.freeTimeCounter / 60)
      minutesString = if minutes.toString().length > 1 then minutes.toString() else "0#{minutes.toString()}"

      ($ "#free_time_remaining").html "#{minutesString}:#{secondsString}"

  paidTimeElapsed: $.timer ->
    ++videoChatTimers.paidTimeCounter
    seconds = videoChatTimers.paidTimeCounter % 60
    minutes = parseInt(videoChatTimers.paidTimeCounter / 60)
    minutes = if seconds is 0 then minutes else minutes + 1

    ($ "#paid_time_elapsed").html "#{minutes.toString()} minute(s)"

window.videoChatTimers = videoChatTimers