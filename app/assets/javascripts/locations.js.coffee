$(".locations.show").ready ->

  # Create a new directed graph
  g = new dagreD3.Digraph()

  # States and transitions from RFC 793
  states = [
    "Einsp/Bezug"
    "Wind_Einsp"
    "PV_1_Einsp"
    "KWK_Einsp"
    "PV_0_Erzeug"
    "KWK_Erzeug"
    "Bezug_1"
    "Bezug_2"
    "Bezug_3"
    "Bezug_4"
    "PV_1_Erzeug"
    "PV_2_Erzeug"
    "Wind_Erzeug"
  ]

  # Automatically label each of the nodes
  states.forEach (state) ->
    g.addNode state,
      label: state

    return

  # Add some custom colors based on state
  g.node("Einsp/Bezug").style = "fill: #06b"
  g.node("Wind_Einsp").style = "fill: #f77"
  g.node("PV_1_Einsp").style = "fill: #f77"
  g.node("KWK_Einsp").style = "fill: #f77"
  g.node("PV_0_Erzeug").style = "fill: #f77"
  g.node("PV_1_Erzeug").style = "fill: #f77"
  g.node("PV_2_Erzeug").style = "fill: #f77"
  g.node("Wind_Erzeug").style = "fill: #f77"
  g.node("KWK_Erzeug").style = "fill: #f77"
  g.node("Bezug_1").style = "fill: #0df"
  g.node("Bezug_2").style = "fill: #0df"
  g.node("Bezug_3").style = "fill: #0df"
  g.node("Bezug_4").style = "fill: #0df"

  # Set up the edges
  g.addEdge null, "Einsp/Bezug", "PV_2_Erzeug"

  g.addEdge null, "Einsp/Bezug", "Wind_Einsp"

  g.addEdge null, "Wind_Einsp", "Wind_Erzeug"

  g.addEdge null, "Wind_Einsp", "PV_1_Einsp"

  g.addEdge null, "PV_1_Einsp", "KWK_Einsp"

  g.addEdge null, "PV_1_Einsp", "PV_0_Erzeug"

  g.addEdge null, "PV_1_Einsp", "PV_1_Erzeug"

  g.addEdge null, "KWK_Einsp", "KWK_Erzeug"

  g.addEdge null, "KWK_Einsp", "Bezug_1"

  g.addEdge null, "KWK_Einsp", "Bezug_2"

  g.addEdge null, "KWK_Einsp", "Bezug_3"

  g.addEdge null, "KWK_Einsp", "Bezug_4"


  # Create the renderer
  renderer = new dagreD3.Renderer()

  # Set up an SVG group so that we can translate the final graph.
  svg = d3.select("svg")
  svgGroup = svg.append("g")

  # Set initial zoom to 75%
  initialScale = 0.75
  oldZoom = renderer.zoom()
  renderer.zoom (graph, svg) ->
    zoom = oldZoom(graph, svg)

    # We must set the zoom and then trigger the zoom event to synchronize
    # D3 and the DOM.
    zoom.scale(initialScale).event svg
    zoom


  # Run the renderer. This is what draws the final graph.
  layout = renderer.run(g, svgGroup)

  # Center the graph
  xCenterOffset = (svg.attr("width") - layout.graph().width * initialScale) / 2
  svgGroup.attr "transform", "translate(" + xCenterOffset + ", 20)"
  svg.attr "height", layout.graph().height * initialScale + 40



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