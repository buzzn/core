MeteringPointsController = Paloma.controller("MeteringPoints")


MeteringPointsController.prototype.show = () ->
  $("#mytab a").click (e) ->
    e.preventDefault()
    $(this).tab "show"

  console.log gon.day_to_hours

  $.plot $("#day_to_hours"), [
    data: gon.day_to_hours
    color: "rgba(230, 40, 40, 0.95)"
    bars:
      show: true,
      lineWidth: 2,
      fill: true,
      barWidth: 0.66,
      fillColor: "rgba(220, 80, 80, 0.80)"
  ]


  $.plot $("#fake_day_to_hours"), [
    data: gon.fake_day_to_hours
    bars:
      show: true
      lineWidth: 4,
      fill: true,
      barWidth: 0.66,
      color: "rgba(255, 85, 80, 0.94)",
      fillColor: "rgba(255, 85, 80, 0.94)"
  ]
