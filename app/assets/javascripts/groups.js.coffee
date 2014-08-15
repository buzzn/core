$(".groups.show").ready ->

  $("#mytab a").click (e) ->
    e.preventDefault()
    $(this).tab "show"



  $ ->
    data = []
    container = $("#register_#{100} #chart")
    maximum = 61

    getRandomData = ->
      data = data.slice(1)  if data.length
      while data.length < maximum
        previous = (if data.length then data[data.length - 1] else 500)
        y = previous + Math.random()*50 - 25
        data.push (if y < 0 then 0 else (if y > 500 then 500 else y))

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
          "Bezug: " + yval + " Watt"
      xaxis:
        tickDecimals: 0
        tickFormatter: (xval) ->
          xval-60

      yaxis:
        min: 0
        max: 600

      legend:
        show: false

      axisLabels:
        show: true
      xaxes:[
        axisLabel: 'Zeit (Sekunden)'
      ]
      yaxes:[
        axisLabel: 'Bezug (Watt)'
      ]
      )

    setInterval (updateRandom = ->
      series[0].data = getRandomData()
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
            previous = (if data.length then data[data.length - 1] else 250)
            y = previous + Math.random()*50 - 25
            data.push (if y < 0 then 0 else (if y > 500 then 500 else y))

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
              "Bezug: " + yval + " Watt"
          xaxis:
            tickDecimals: 0
            tickFormatter: (xval) ->
              xval-60

          yaxis:
            min: 0
            max: 600

          legend:
            show: false

          axisLabels:
            show: true
          xaxes:[
            axisLabel: 'Zeit (Sekunden)'
          ]
          yaxes:[
            axisLabel: 'Bezug (Watt)'
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
        data = []
        container = $("#register_#{register_chart.id} #chart")
        maximum = 61

        getRandomData = ->
          data = data.slice(1)  if data.length
          while data.length < maximum
            previous = (if data.length then data[data.length - 1] else 500)
            y = previous + Math.random()*100 - 50
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
              "Einspeisung: " + yval + " Watt"
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
            axisLabel: 'Einspeisung (Watt)'
          ]
          )

        setInterval (updateRandom = ->
          series[0].data = getRandomData()
          plot.setData series
          plot.draw()
          return
        ), 1000
        return


