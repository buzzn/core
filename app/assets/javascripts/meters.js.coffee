MetersController = Paloma.controller("Meters")

MetersController.prototype.index = () ->
  $('.inlinebar').sparkline 'html',
    type: 'bar',
    barColor: '#00e',
    height: 50,
    barWidth: 8