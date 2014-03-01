MetersController = Paloma.controller("Meters")

MetersController.prototype.index = () ->
  $('.inlinebar').sparkline 'html', 
    type: 'bar', 
    barColor: '#f00',
    height: 30,
    barWidth: 10