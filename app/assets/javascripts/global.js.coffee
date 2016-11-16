window.wwasInactive = true
window.wisActive = true
ttlastSample = new Date()
rem_page_id = ""
randomvalue = "12345678"

window.addEventListener 'pageshow', (event)->
  randomvalue = Math.random()
  #console.log("page_show " + randomvalue)
  window.wisActive = true
  window.wwasInactive = false

window.addEventListener 'pagehide', (event)->
  window.wisActive = false

window.addEventListener 'focus', (event)->
  delta = Date.now() - ttlastSample
  if delta >= 40000
    location.reload()
  ttlastSample = Date.now()
  randomvalue = Math.random()
  #console.log("focus " + randomvalue)
  window.wisActive = true
#  actual_resolution = "hour_to_minutes"
#  containing_timestamp = chart_data_min_x
#  setChartData('registers', id, containing_timestamp)


window.addEventListener 'blur', (event)->
  window.wisActive = false
  window.wwasInactive = true


ready = ->
  FastClick.attach(document.body);
  $(".nano").nanoScroller();
  $(".select2").select2()
  $('.selectpicker').selectpicker();
  $('a[rel~="tooltip"]').tooltip()
  $('[data-tooltip="true"]').tooltip();

  $("body").on "hidden.bs.modal", ".modal", ->
    $('.modal-dialog').empty()

  $("body").on "show.bs.modal", ".modal", ->
    $(".tour-tour").fadeOut()

  $(".js-dependent-fields").waitUntilExists( ->
    DependentFields.bind()
  )

  $("#menu").metisMenu()

  $('.fa-info-circle').popover(placement: 'right', trigger: "hover" )

  $('.change-order').popover(placement: 'right', trigger: "hover" )

  $('.readability').tooltip({container: 'body'})

  $(".likes").tooltip({html: true, container: 'body'})

  $('[data-toggle="popover"]').popover(trigger: "hover")

  $(".modal-content").waitUntilExists( ->
    $('.fa-info-circle').popover(placement: 'right', trigger: "hover" )
  )

  $(".embed").on 'click', ->
    if $(".embed-code").css("display") == 'none'
      $(".embed-code").show()
    else
      $(".embed-code").hide()


  $('body').on 'click', (e) ->
    $('.fa-info-circle').each ->
      #the 'is' for buttons that trigger popups
      #the 'has' for icons within a button that triggers a popup
      if !$(this).is(e.target) and $(this).has(e.target).length == 0 and $('.popover').has(e.target).length == 0
        $(this).popover 'hide'

  $('.fancy-image').fancybox(
    openEffect: 'elastic'
    closeEffect: 'elastic'
    helpers:
      title:
        type: 'float'
  )

  $('.fancy-gallery').fancybox(
    openEffect: 'elastic'
    closeEffect: 'elastic'
  )


  window.addEventListener 'resize:end', (event) ->
    console.log event.type

  $('.mainnav-toggle').on 'click', ->
    resizeChart(500)


  $(window).on 'resize:end', ->
    resizeChart(300)




  Highcharts.setOptions(
    lang:
      weekdays: ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]
      months: ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"]
      shortMonths: ["Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"]
  )

  $('.typeahead').typeahead()

  $(".chart-comment-form-close").on "click", ->
    $('.chart-comment-form').hide 100
    $('.chart-comment-form').find('#comment_body').val('')

$(".error-not-found").ready ->
  $("#container").css("background-color", "black")
  $("#content-container").css("background-color", "black")




$(document).ready(ready)
$(document).on('page:load', ready)
$(document).on('show.bs.modal', ready)
$(document).on('page:restore', ->
  $(window).trigger('resize')
timers = []

  timers.push(window.setInterval(->
    sleepDetect(randomvalue)
    return
  , 1000*19)
  )
)

sleepDetect = (page_id) ->
  delta = Date.now() - ttlastSample
  if delta >= 40000 && page_id == rem_page_id
    # Code here will only run if the timer is delayed by more 2X the sample rate
    # (e.g. if the laptop sleeps for more than 20-40 seconds)
    # Finetuning of times may be necessary
    location.reload()
  #else
  #  console.log('always awake ' + delta + " PID: " +  page_id)
  rem_page_id = page_id
  ttlastSample = Date.now()


resizeChart = (duration) ->
  setTimeout (->
    chartDivs = $(".chart")
    chartDivs.each (div) ->
      chart = $("#" + $(this).attr('id')).highcharts()
      if chart != undefined
        chart.setSize($(this).width(), $(this).height(), doAnimation = false)
        Chart.Functions.resizeChartComments(false)
    return
  ), duration
  return



(($) ->

  ###*
  * @function
  * @property {object} jQuery plugin which runs handler function once specified element is inserted into the DOM
  * @param {function} handler A function to execute at the time when the element is inserted
  * @param {bool} shouldRunHandlerOnce Optional: if true, handler is unbound after its first invocation
  * @example $(selector).waitUntilExists(function);
  ###

  $.fn.waitUntilExists = (handler, shouldRunHandlerOnce, isChild) ->
    found = 'found'
    $this = $(@selector)
    $elements = $this.not(->
      $(this).data found
    ).each(handler).data(found, true)
    if !isChild
      (window.waitUntilExists_Intervals = window.waitUntilExists_Intervals or {})[@selector] = window.setInterval((->
        $this.waitUntilExists handler, shouldRunHandlerOnce, true
        return
      ), 500)
    else if shouldRunHandlerOnce and $elements.length
      window.clearInterval window.waitUntilExists_Intervals[@selector]
    $this

  return
) jQuery


#setInterval (->
#  console.log if wisActive then 'active' else 'inactive'
#  return
#), 1000





