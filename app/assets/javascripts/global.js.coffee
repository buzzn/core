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

$(document).ready(ready)
$(document).on('page:load', ready)
$(document).on('show.bs.modal', ready)






