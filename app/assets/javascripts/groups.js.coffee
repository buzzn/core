$(".groups.show").ready ->

  $("#mytab a").click (e) ->
    e.preventDefault()
    $(this).tab "show"

  dataOut = []
  containerDisplay = $("#register_#{100} #chart")
  maximum = 61

  getRandomDataOut = ->
    dataOut = dataOut.slice(1)  if dataOut.length
    while dataOut.length < maximum
      previous = (if dataOut.length then dataOut[dataOut.length - 1] else 500)
      y = previous + Math.random()*100 - 50
      dataOut.push (if y < 0 then 0 else (if y > 1000 then 1000 else y))

    res = []
    i = 0

    while i < dataOut.length
      res.push [
        i
        dataOut[i]
      ]
      ++i
    res

  $ ->

    data = []
    maximum = 61

    getRandomData = ->
      data = data.slice(1)  if data.length
      while data.length < maximum
        previous = (if data.length then data[data.length - 1] else 500)
        y = previous + Math.random()*100 - 48
        data.push (if y < 0 then 0 else (if y > 1000 then 1000 else y))

      res = []
      i = 0

      while i < data.length
        res.push [
          i
          data[i]
        ]
        ++i
      res
    #
    series = [[
      data: getRandomDataOut()
      color: "#FF8A65"
      points:
        show: false
      lines:
        show: true
        fill: true
        fillColor: "rgba(255,255,255,0.1)"
        lineWidth: 3
      hoverable: true
      highlightColor: "rgba(255, 255, 255, 0.5)"
    ], [
      data: getRandomData()
      color: "#52AEFF"
      points:
        show: false
      lines:
        show: true
        fill: true
        fillColor: "rgba(255,255,255,0.1)"
        lineWidth: 3
      hoverable: true
      highlightColor: "rgba(255, 255, 255, 0.5)"
    ]
    ]

    series[0].label = "Produktion"
    series[1].label = "Verbrauch"
    #
    plot = $.plot(containerDisplay, series,
      lines:
        show: true
        fill: true
        fillColor: "rgba(255,255,255,0.05)"
        lineWidth: 3
      legend:
        show: false
      grid:
        show: true
        color: "white"
        borderWidth: 0
        hoverable: true
      tooltip: true
      tooltipOpts:
        content: (label, xval, yval, flotItem) ->
          label + ": " + yval.toFixed(0) + " Watt"
      xaxis:
        tickDecimals: 0
        tickFormatter: (xval) ->
          xval-60

      yaxis:
        min: 0
        max: 1100

      axisLabels:
        show: true
      xaxes:[
        axisLabel: 'Zeit (Sekunden)'
      ]
      yaxes:[
        axisLabel: 'Leistung (Watt)'
      ]
      )

    setInterval (updateRandom = ->
      series[0].data = getRandomDataOut()
      series[1].data = getRandomData()
      plot.setData series
      plot.draw()
      return
    ), 1000
    return





  for register_chart in gon.register_charts
    console.log register_chart
    if register_chart.id != 16
      $ ->
        data = []
        container = $("#register_#{register_chart.id} #chart")
        maximum = 61

        getRandomData = ->
          data = data.slice(1)  if data.length
          while data.length < maximum
            previous = (if data.length then data[data.length - 1] else 200)
            y = previous + Math.random()*40 - 21
            data.push (if y < 0 then 0 else (if y > 400 then 400 else y))

          res = []
          i = 0

          while i < data.length
            res.push [
              i
              data[i]
            ]
            ++i
          res

        #
        series = [
          data: getRandomData()
          color: "white"
          points:
            show: false
          lines:
            show: true
            fill: true
            fillColor: "rgba(255,255,255,0.1)"
            lineWidth: 3
          hoverable: true
          highlightColor: "rgba(255, 255, 255, 0.5)"
        ]

        #
        plot = $.plot(container, series,
          grid:
            show: true
            color: "white"
            borderWidth: 0
            hoverable: true
          tooltip: true
          tooltipOpts:
            content: (label, xval, yval, flotItem) ->
              "Verbrauch: " + yval.toFixed(0) + " Watt"
          xaxis:
            tickDecimals: 0
            tickFormatter: (xval) ->
              xval-60

          yaxis:
            min: 0
            max: 500

          legend:
            show: false

          axisLabels:
            show: true
          xaxes:[
            axisLabel: 'Zeit (Sekunden)'
          ]
          yaxes:[
            axisLabel: 'Verbrauch (Watt)'
          ]
          )

        setInterval (updateRandom = ->
          series[0].data = getRandomData()
          plot.setData series
          plot.draw()
          return
        ), 1000
        return
    else
      $ ->
        container = $("#register_#{register_chart.id} #chart")
        maximum = 61

        #
        series = [
          data: getRandomDataOut()
          color: "white"
          points:
            show: false
          lines:
            show: true
            fill: true
            fillColor: "rgba(255,255,255,0.07)"
            lineWidth: 3
          hoverable: true
          highlightColor: "rgba(255, 255, 255, 0.5)"
        ]

        #
        plot = $.plot(container, series,
          grid:
            show: true
            color: "white"
            borderWidth: 0
            hoverable: true
          tooltip: true
          tooltipOpts:
            content: (label, xval, yval, flotItem) ->
              "Produktion: " + yval.toFixed(0) + " Watt"
          xaxis:
            tickDecimals: 0
            tickFormatter: (xval) ->
              xval-60

          yaxis:
            min: 0
            max: 1100

          legend:
            show: false

          axisLabels:
            show: true
          xaxes:[
            axisLabel: 'Zeit (Sekunden)'
          ]
          yaxes:[
            axisLabel: 'Produktion (Watt)'
          ]
          )

        setInterval (updateRandom = ->
          series[0].data = getRandomDataOut()
          plot.setData series
          plot.draw()
          return
        ), 1000
        return


