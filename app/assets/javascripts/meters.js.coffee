MetersController = Paloma.controller("Meters")


MetersController.prototype.edit = () ->
  AddressPickerRails.Pickers.applyOnReady()

MetersController.prototype.new = () ->
  AddressPickerRails.Pickers.applyOnReady()
