calculateNameWidth = ->
  headerWidth = $(".header").width()
  btnWidth = $(".btn.btn-default.pull-right").outerWidth()
  signWidth = $(".marker-box").outerWidth()
  $(".metering_point_name").width headerWidth - btnWidth - signWidth - 50
  return

ready = ->
  $(".select2").select2()
  $('a[rel~="tooltip"]').tooltip()
  DependentFields.bind()

  $("body").on "hidden.bs.modal", ".modal", ->
    $(this).empty()

  $(".metering_point_name").on "mouseenter", ->
    $this = $(this)
    $this.attr "title", $this.text()  if @offsetWidth < @scrollWidth and not $this.attr("title")
    return

  $(window).on "resize", calculateNameWidth

  calculateNameWidth()

  # pusher test -----------------------------
  Pusher.host    = 'localhost'
  Pusher.ws_port = 8080
  Pusher.wss_port = 8080
  pusher = new Pusher("83f4f88842ce2dc76b7b")

  channel = pusher.subscribe("register_0")
  console.log "subscribed to channel register_0"

  channel.bind "update", (reading) ->
    console.log reading
  #-------------------------------------------


$(document).ready(ready)
$(document).on('page:load', ready)
$(document).on('show.bs.modal', ready)



