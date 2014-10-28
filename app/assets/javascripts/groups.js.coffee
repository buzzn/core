$(".groups.show").ready ->
  $("#mytab a").click (e) ->
    e.preventDefault()
    $(this).tab "show"

  # Javascript to enable link to tab
  hash = document.location.hash
  prefix = "tab_"
  $(".nav-pills a[href=" + hash.replace(prefix, "") + "]").tab "show"  if hash

  # Change hash for page-reload
  $(".nav-pills a").on "shown.bs.tab", (e) ->
    window.location.hash = e.target.hash.replace("#", "#" + prefix)
    return

  $("a[data-toggle=\"tab\"]").on "shown.bs.tab", (e) ->
    target_click = e.target.toString().slice(e.target.toString().lastIndexOf("#"), e.target.length)
    if target_click == "#metering_points"
      init_charts()

  init_charts = ->
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


  if hash == "#metering_points" || hash == "tab_metering_points" || hash == ""
    init_charts()


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
    .on "ajax:error", (evt, data, status, xhr) ->
      $(this).find('textarea')
        .removeClass('uneditable-input')
        .removeAttr('disabled', 'disabled');

  # Delete a comment
  $(document)
    .on "ajax:beforeSend", ".comment", ->
      $(this).fadeTo('fast', 0.5)
    .on "ajax:success", ".comment", ->
      $(this).hide('fast')
    .on "ajax:error", ".comment", ->
      $(this).fadeTo('fast', 1)