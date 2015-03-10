ready = ->
  $(".select2").select2()
  $('a[rel~="tooltip"]').tooltip()
  $('[data-tooltip="true"]').tooltip();
  DependentFields.bind()

  $("body").on "hidden.bs.modal", ".modal", ->
    $('.modal-dialog').empty()

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






