calculateNameWidth = ->
  headerWidth = $(".header").width()
  btnWidth = $(".btn.btn-default.pull-right").outerWidth()
  signWidth = $(".marker-box").outerWidth()
  $(".metering_point_name").width headerWidth - btnWidth - signWidth - 50
  return

readingsSLP = []

getSLPValue = ->
  $.getJSON "/metering_points/1/latest_slp", (data) ->
    readingsSLP = data

setSLPValue = ->
  if Date.parse(readingsSLP[1][0]) < new Date()
    getSLPValue()
  $(".slp_ticker").html "Aktueller Bezug: " + interpolateSLPkW().toFixed(0) + " W"

interpolateSLPkW = ->
  firstTimestamp = readingsSLP[0][0]
  firstValue = readingsSLP[0][1]
  lastTimestamp = readingsSLP[1][0]
  lastValue = readingsSLP[1][1]
  averagePower = (lastValue - firstValue)/0.25*1000
  return getRandomPower(averagePower)


getRandomPower = (averagePower) ->
  y = averagePower + Math.random()*10 - 5
  if y < 0
    return 0
  else
    return y

timers = []

clearTimers = ->
  i = 0
  while i < timers.length
    window.clearInterval timers[i]
    i++
  timers = []

ready = ->
  $(".select2").select2()
  $('a[rel~="tooltip"]').tooltip()
  DependentFields.bind()

  $("body").on "hidden.bs.modal", ".modal", ->
    $('.modal-dialog').empty()

  $(".metering_point_name").on "mouseenter", ->
    $this = $(this)
    $this.attr "title", $this.text()  if @offsetWidth < @scrollWidth and not $this.attr("title")
    return

  $(window).on "resize", calculateNameWidth

  calculateNameWidth()

  if $(".slp_ticker").length != 0 && timers.length == 0
    getSLPValue()
    timers.push(
      window.setInterval(->
        setSLPValue()
        return
      , 1000*2)
      )







$(document).ready(ready)
$(document).on('page:load', ready)
$(document).on('show.bs.modal', ready)
$(document).on('page:before-change', clearTimers)



