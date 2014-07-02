MeteringPointsController = Paloma.controller("MeteringPoints")


MeteringPointsController.prototype.show = () ->
  $("#mytab a").click (e) ->
    e.preventDefault()
    $(this).tab "show"

  $.plot $("#bar_chart"), [
    data: gon.day_to_hours
    color: "rgba(230, 40, 40, 0.94)"
    bars:
      show: true,
      lineWidth: 2,
      fill: true,
      barWidth: 0.66,
      fillColor: "rgba(220, 80, 80, 0.80)"
  ]

