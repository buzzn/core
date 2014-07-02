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
      fillColor: "rgba(255, 50, 50, 0.90)"
  ]

