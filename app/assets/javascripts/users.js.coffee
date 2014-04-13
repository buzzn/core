UsersController = Paloma.controller("Users")


UsersController.prototype.show = () ->
  $('.inlinebar').sparkline 'html',
    type: 'bar',
    barColor: '#00e',
    height: 100,
    barWidth: 580/24
