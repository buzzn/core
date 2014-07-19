$(".groups.show").ready ->

  $("#mytab a").click (e) ->
    e.preventDefault()
    $(this).tab "show"
