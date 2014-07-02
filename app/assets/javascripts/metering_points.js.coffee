MeteringPointsController = Paloma.controller("MeteringPoints")


MeteringPointsController.prototype.show = () ->
  $("#mytab a").click (e) ->
    e.preventDefault()
    $(this).tab "show"

  $.plot $("#bar_chart"), [
    data: gon.day_to_hours
    bars:
      show: true
      lineWidth: 2,
      fill: true,
      barWidth: 0.66,
      fillColor: "rgba(220, 80, 80, 0.90)"
  ]

