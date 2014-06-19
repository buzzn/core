LocationsController = Paloma.controller("Locations")

LocationsController.prototype.show = () ->
  $('.inlinebar').sparkline 'html',
    type: 'bar',
    height: 60,
    barWidth: 14