calculateNameWidth = ->
  headerWidth = $(".header").width()
  btnWidth = $(".btn.btn-default.pull-right").outerWidth()
  signWidth = $(".marker-box").outerWidth()
  $(".metering_point_name").width headerWidth - btnWidth - signWidth - 50
  return

ready = ->
  $(".select2").select2()
  $('a[rel~="tooltip"]').tooltip()
  $('[data-tooltip="true"]').tooltip();
  DependentFields.bind()

  $("body").on "hidden.bs.modal", ".modal", ->
    $('.modal-dialog').empty()

  $(".metering_point_name").on "mouseenter", ->
    $this = $(this)
    $this.attr "title", $this.text()  if @offsetWidth < @scrollWidth and not $this.attr("title")
    return

  $(window).on "resize", calculateNameWidth

  calculateNameWidth()

$(document).ready(ready)
$(document).on('page:load', ready)
$(document).on('show.bs.modal', ready)



