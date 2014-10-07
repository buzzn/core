$(".locations.show").ready ->

  # Create the input graph
  g = new dagreD3.Digraph()

  # Fill node 'A' with the color green
  g.addNode "A",
    label: "A"
    style: "fill: #afa;"


  # Make the label for node 'B' bold
  g.addNode "B",
    label: "B"
    labelStyle: "font-weight: bold;"


  # Double the size of the font for node 'C'
  g.addNode "C",
    label: "C"
    labelStyle: "font-size: 2em;"


  # Make the edge from 'A' to 'B' red and thick
  g.addEdge null, "A", "B",
    style: "stroke: #f66; stroke-width: 3px;"


  # Make the label for the edge from 'C' to 'B' italic and underlined
  g.addEdge null, "C", "B",
    label: "A to C"
    style: "stroke-width: 1.5px"
    labelStyle: "font-style: italic; text-decoration: underline;"


  # Create the renderer
  renderer = new dagreD3.Renderer()

  # Disable pan / zoom for this demo
  renderer.zoom false

  # Set up an SVG group so that we can translate the final graph.
  svg = d3.select("svg")
  svgGroup = svg.append("g")

  # Run the renderer. This is what draws the final graph.
  layout = renderer.run(g, svgGroup)

  # Center the graph
  xCenterOffset = (svg.attr("width") - layout.graph().width) / 2
  svgGroup.attr "transform", "translate(" + xCenterOffset + ", 20)"
  svg.attr "height", layout.graph().height + 40



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