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
    console.log 'jo'

  $(".js-dependent-fields").waitUntilExists( ->
    DependentFields.bind()
  )

  $('.fa-info-circle').popover(placement: 'right', trigger: "hover" )

  $(".modal-content").waitUntilExists( ->
    $('.fa-info-circle').popover(placement: 'right', trigger: "hover" )
  )


  $('body').on 'click', (e) ->
    $('.fa-info-circle').each ->
      #the 'is' for buttons that trigger popups
      #the 'has' for icons within a button that triggers a popup
      if !$(this).is(e.target) and $(this).has(e.target).length == 0 and $('.popover').has(e.target).length == 0
        $(this).popover 'hide'


  window.addEventListener 'resize:end', (event) ->
    console.log event.type

  $('.mainnav-toggle').on 'click', ->
    resizeChart(500)


  $(window).on 'resize', ->
    resizeChart(0)



  Highcharts.setOptions(
    lang:
      weekdays: ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]
      months: ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"]
      shortMonths: ["Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"]
  )

  $('.typeahead').typeahead()

$(document).ready(ready)
$(document).on('page:load', ready)
$(document).on('show.bs.modal', ready)
$(document).on('page:restore', ->
  $(window).trigger('resize')
)

resizeChart = (duration) ->
  setTimeout (->
    chartDivs = $(".chart")
    chartDivs.each (div) ->
      chart = $("#" + $(this).attr('id')).highcharts()
      if chart != undefined
        chart.setSize($(this).width(), $(this).height(), doAnimation = false)
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





