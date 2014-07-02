MeteringPointsController = Paloma.controller("MeteringPoints")


MeteringPointsController.prototype.show = () ->
  $("#mytab a").click (e) ->
    e.preventDefault()
    $(this).tab "show"

  console.log gon.day_to_hours
  

  $.plot $("#bar_chart"), [
    data: [[0, 3], [1, 3], [2, 5], [3, 7], [4, 8], [5, 10], [6, 11], [7, 9], [8, 5], [9, 18]]
    bars: {
    show: true,
    lineWidth: 4,
    fill: true,
    barWidth: 0.66,
    color: "rgba(255, 85, 80, 0.94)",
    fillColor: "rgba(255, 85, 80, 0.94)"
    }
  ]
