ready = ->
  FastClick.attach(document.body);
  $(".select2").select2()
  $('a[rel~="tooltip"]').tooltip()
  $('[data-tooltip="true"]').tooltip();
  DependentFields.bind()

  $("body").on "hidden.bs.modal", ".modal", ->
    $('.modal-dialog').empty()

  $('.fa-info-circle').popover(placement: 'right')

  $('body').on 'click', (e) ->
    $('.fa-info-circle').each ->
      #the 'is' for buttons that trigger popups
      #the 'has' for icons within a button that triggers a popup
      if !$(this).is(e.target) and $(this).has(e.target).length == 0 and $('.popover').has(e.target).length == 0
        $(this).popover 'hide'

  $(window).on 'resize', ->
    chartDivs = $(".chart")
    chartDivs.each (div) ->
      chart = $("#" + $(this).attr('id')).highcharts()
      if chart != undefined
        chart.setSize($(this).width(), $(this).height(), doAnimation = false)

  Highcharts.setOptions(
    lang:
      weekdays: ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]
      months: ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"]
      shortMonths: ["Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"]
  )

$(document).ready(ready)
$(document).on('page:load', ready)
$(document).on('show.bs.modal', ready)
$(document).on('page:restore', ->
  $(window).trigger('resize')
)






