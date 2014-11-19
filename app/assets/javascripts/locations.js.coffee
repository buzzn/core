$(".locations.show").ready ->

  init_tree = ->
    url = document.URL.substring(0, document.URL.lastIndexOf('#'))
    $.getJSON url + ".json", (data) ->
      json = JSON.stringify(data).substring(13, JSON.stringify(data).length - 1)
      $("#tree1").tree
        data: JSON.parse(json)
        autoOpen: true
        dragAndDrop: true
      return

  # Javascript to enable link to tab
  hash = document.location.hash
  $(".nav-pills a[href=" + hash + "]").tab "show"  if hash

  # Change hash for page-reload
  $(".nav-pills a").on "shown.bs.tab", (e) ->
    window.location.hash = e.target.hash
    return


  $("a[data-toggle=\"tab\"]").on "shown.bs.tab", (e) ->
    target_click = e.target.toString().slice(e.target.toString().lastIndexOf("#"), e.target.length)
    if target_click == "#metering_point_tree"
      init_tree()
    if target_click == "#metering_points"
      init_charts()






  init_charts = ->
    for register in gon.registers
      $.plot $("#register_#{register.id} #chart"), [register['current']], {
        series:
          color: "white"
          points:
            show: false
          bars:
            show: true
            fill: true
            fillColor: "rgba(255,255,255, 0.94)"
            barWidth: 0.66 * 3600 * 1000
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





  if hash == "#tab_metering_point_tree" || hash == "#metering_point_tree"
    init_tree()
  else
    init_charts()


  return