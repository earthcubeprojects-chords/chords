# This library fixes common problems with turbolinks
# - Overwrite setTimeout and setInterval to intercept generated ID's
# - Keep track of Ajax requests
#
# When turbolinks' unload event is called, we:
# - Cancel all setTimeouts and setIntervals
# - Abort all still running Ajax requests


$.turboTurbo =
  xhrPool: [],
  setTimeoutPool: [],
  setIntervalPool: [],

  setup: ->
    window.turboTurboSetTimeout = window.setTimeout
    window.turboTurboSetInterval = window.setInterval

    window.setTimeout = (func, delay) ->
      timeoutId = window.turboTurboSetTimeout(func, delay)
      $.turboTurbo.setTimeoutPool.push(timeoutId)
      timeoutId

    window.setInterval = (func, interval) ->
      intervalId = window.turboTurboSetInterval(func, interval)
      $.turboTurbo.setIntervalPool.push(intervalId)
      intervalId

    $.ajaxSetup
      beforeSend: (jqXHR) -> $.turboTurbo.xhrPool.push(jqXHR),
      complete:   (jqXHR) -> $.turboTurbo.xhrPool.splice($.inArray(jqXHR, $.turboTurbo.xhrPool), 1),

    $(document).on "page:before-unload", ->
      $.turboTurbo.unload()

  unload: ->
    while xhr = $.turboTurbo.xhrPool.pop()
      xhr.abort()

    while timeoutId = $.turboTurbo.setTimeoutPool.pop()
      clearTimeout(timeoutId)

    while intervalId = $.turboTurbo.setIntervalPool.pop()
      clearInterval(intervalId)
      
$.turboTurbo.setup()