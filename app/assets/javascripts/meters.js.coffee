MetersController = Paloma.controller("Meters")

MetersController.prototype.index = () ->
  $('.inlinebar').sparkline 'html',
    type: 'bar',
    barColor: '#00e',
    height: 80,
    barWidth: 15


MetersController.prototype.edit = () ->
  AddressPickerRails.Pickers.applyOnReady()

MetersController.prototype.new = () ->
  AddressPickerRails.Pickers.applyOnReady()
