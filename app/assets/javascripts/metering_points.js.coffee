MeteringPointsController = Paloma.controller("MeteringPoints")


MeteringPointsController.prototype.show = () ->
  $("#mytab a").click (e) ->
    e.preventDefault()
    $(this).tab "show"

  $.plot $("#bar_chart"), [
    data: gon.day_to_hours
    bars:
      show: true
      lineWidth: 4,
      fill: true,
      barWidth: 0.66,
      color: "rgba(255, 85, 80, 0.94)",
      fillColor: "rgba(255, 85, 80, 0.94)"
  ]

