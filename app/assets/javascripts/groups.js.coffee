$(".groups.show").ready ->
  $("#mytab a").click (e) ->
    e.preventDefault()
    $(this).tab "show"

  for register_chart in gon.register_charts
    $.plot $("#register_#{register_chart.id} #chart"), [register_chart['current']], {
      series:
        color: "white"
      points:
        show: false
      bars:
        show: true
        fill: true
        fillColor: "rgba(255,255,255,0.94)"
        barWidth: 0.66*3600*1000
        lineWidth: 0
        hoverable: true
        highlightColor: "rgba(255, 255, 255, 0.5)"
      grid:
        show: true
        color: "white"
        borderWidth: 0
        hoverable: true
      xaxis:
        mode: "time"
        timeformat: "%H:%M"
        tickDecimals: 0
        timezone: "browser"
        max: gon.end_of_day
      tooltip: true
      tooltipOpts:
        content: (label, xval, yval, flotItem) ->
          new Date(xval).getHours() + ":00 bis " + new Date(xval).getHours() + ":59 Uhr, Bezug: " + yval + " kWh"
      axisLabels:
        show: true
      xaxes:[
        axisLabel: 'Uhrzeit'
      ]
      yaxes:[
        axisLabel: 'Bezug (kWh)'
      ]
    }

jQuery ->
  # Create a comment
  $(".comment-form")
    .on "ajax:beforeSend", (evt, xhr, settings) ->
      $(this).find('textarea')
        .addClass('uneditable-input')
        .attr('disabled', 'disabled');
    .on "ajax:success", (evt, data, status, xhr) ->
      $(this).find('textarea')
        .removeClass('uneditable-input')
        .removeAttr('disabled', 'disabled')
        .val('');
      $(xhr.responseText).hide().insertAfter($(this)).show('slow')

  # Delete a comment
  $(document)
    .on "ajax:beforeSend", ".comment", ->
      $(this).fadeTo('fast', 0.5)
    .on "ajax:success", ".comment", ->
      $(this).hide('fast')
    .on "ajax:error", ".comment", ->
      $(this).fadeTo('fast', 1)