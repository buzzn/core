LocationsController = Paloma.controller("Locations")

LocationsController.prototype.show = () ->
  $('.inlinebar').sparkline 'html',
    type: 'bar',
    height: 60,
    width: 300