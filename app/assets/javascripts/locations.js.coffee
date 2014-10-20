$(".locations.show").ready ->
  init_tree = ->
    $.getJSON document.URL + ".json", (data) ->
      json = JSON.parse(JSON.stringify(data).substr(1, JSON.stringify(data).length - 2))

      #I'm setting this based on the fact that ExCanvas provides text support for IE
      #and that as of today iPhone/iPad current text support is lame

      #Create a node rendering function that plots a fill
      #rectangle and a stroke rectangle for borders
      $jit.ST.Plot.NodeTypes.implement "stroke-rect":
        render: (node, canvas) ->
          width = node.getData("width")
          height = node.getData("height")
          pos = @getAlignedPos(node.pos.getc(true), width, height)
          posX = pos.x + width / 2
          posY = pos.y + height / 2
          @nodeHelper.rectangle.render "fill",
            x: posX
            y: posY
          , width, height, canvas
          @nodeHelper.rectangle.render "stroke",
            x: posX
            y: posY
          , width, height, canvas
          return
      #init data

      #end
      #init Spacetree
      #Create a new ST instance

      #id of viz container element

      #set duration for the animation

      #set animation transition type

      #set distance between node and its children

      #enable panning

      #set node and edge styles
      #set overridable=true for styling individual
      #nodes or edges

      #This method is called on DOM label creation.
      #Use this method to add event handlers and styles to
      #your node.

      #set label styles

      #This method is called right before plotting
      #a node. It's useful for changing an individual node
      #style properties before plotting it.
      #The data properties prefixed with a dollar
      #sign will override the global node style properties.

      #add some color to the nodes in the path between the
      #root node and the selected node.

      #if the node belongs to the last plotted level

      #count children number

      #assign a node color based on
      #how many children it has

      #This method is called right before plotting
      #an edge. It's useful for changing an individual edge
      #style properties before plotting it.
      #Edge data proprties prefixed with a dollar sign will
      #override the Edge global style properties.

      #load json data

      #compute node positions and layout

      #optional: make a translation of the tree

      #emulate a click on the root node.

      #end
      #Add event handlers to switch spacetree orientation.
      changeHandler = ->
        if @checked
          top.disabled = bottom.disabled = right.disabled = left.disabled = true
          st.switchPosition @value, "animate",
            onComplete: ->
              top.disabled = bottom.disabled = right.disabled = left.disabled = false
              return

        return







      st = new $jit.ST(
        injectInto: "infovis"
        duration: 800
        transition: $jit.Trans.Quart.easeInOut
        levelDistance: 40
        Navigation:
          enable: true
          panning: true

        Node:
          height: 20
          width: 100
          type: "stroke-rect"
          #color: "#aaa"
          CanvasStyles:
            strokeStyle: '#555',
            lineWidth: 1
          overridable: true

        Edge:
          type: "bezier"
          overridable: true

        onCreateLabel: (label, node) ->
          label.id = node.id
          label.innerHTML = node.name
          label.onclick = ->
            if normal.checked
              st.onClick node.id
            else
              st.setRoot node.id, "animate"
            return

          style = label.style
          style.width = 100 + "px"
          style.height = 17 + "px"
          style.cursor = "pointer"
          style.color = "#333"       #font color
          style.fontSize = "0.8em"
          style.textAlign = "center"
          style.paddingTop = "3px"
          return

        onBeforePlotNode: (node) ->
          if node.data.mode == "in"
            node.data.$color = "#0cf"
          else if node.data.mode == "out"
            node.data.$color = "#f52"
          else if node.data.mode == "in_out"
            node.data.$color = "#90e"
          #if node.selected
          #  node.data.$color = "#ff7"    #yellow if node is in the selected line
          #else
          #  delete node.data.$color

            #unless node.anySubnode("exist")   #another color for node with subnodes
            #  count = 0
            #  node.eachSubnode (n) ->
            #    count++
            #    return

            #  node.data.$color = [
            #    "#aaa"
            #    "#baa"
            #    "#caa"
            #    "#daa"
            #    "#eaa"
            #    "#faa"
            #  ][count]
          #return

        onBeforePlotLine: (adj) ->
          if adj.nodeFrom.selected and adj.nodeTo.selected
            adj.data.$color = "#eed"
            adj.data.$lineWidth = 3
          else
            delete adj.data.$color

            delete adj.data.$lineWidth
          return
      )
      st.loadJSON json
      st.compute()
      st.geom.translate new $jit.Complex(-200, 0), "current"
      st.onClick st.root
      top = $jit.id("r-top")
      left = $jit.id("r-left")
      bottom = $jit.id("r-bottom")
      right = $jit.id("r-right")
      normal = $jit.id("s-normal")
      top.onchange = left.onchange = bottom.onchange = right.onchange = changeHandler
      return

      labelType = undefined
      useGradients = undefined
      nativeTextSupport = undefined
      animate = undefined
      (->
        ua = navigator.userAgent
        iStuff = ua.match(/iPhone/i) or ua.match(/iPad/i)
        typeOfCanvas = typeof HTMLCanvasElement
        nativeCanvasSupport = (typeOfCanvas is "object" or typeOfCanvas is "function")
        textSupport = nativeCanvasSupport and (typeof document.createElement("canvas").getContext("2d").fillText is "function")
        labelType = (if (not nativeCanvasSupport or (textSupport and not iStuff)) then "Native" else "HTML")
        nativeTextSupport = labelType is "Native"
        useGradients = nativeCanvasSupport
        animate = not (iStuff or not nativeCanvasSupport)
        return
      )()

      #end




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
    if target_click == "#metering_point_tree"
      init_tree()
      top = $jit.id("r-top")
      top.checked = true
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