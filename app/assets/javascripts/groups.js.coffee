GroupsController = Paloma.controller("Groups")

GroupsController.prototype.show = () ->
  $("#mytab a").click (e) ->
    e.preventDefault()
    $(this).tab "show"
