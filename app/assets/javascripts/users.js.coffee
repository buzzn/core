UsersController = Paloma.controller("Users")

UsersController.prototype.show = () ->
  $('.inlinebar').sparkline 'html',
    type: 'bar',
    barColor: '#00e',
    height: 100,
    barWidth: 580/24

  $(document).on "click", ".start_modal", (e) ->
    e.preventDefault();
    location_id = $(this).data("location_id")
    $("#myModal").attr("data-location_id", location_id)

  $("#myModal").bind 'ajax:complete', (e, data, status, xhr) ->
    $("#myModal").modal('hide')