ready = ->
  $(".select2").select2()
  $('a[rel~="tooltip"]').tooltip()
  $('[data-tooltip="true"]').tooltip();
  DependentFields.bind()

  $("body").on "hidden.bs.modal", ".modal", ->
    $('.modal-dialog').empty()

$(document).ready(ready)
$(document).on('page:load', ready)
$(document).on('show.bs.modal', ready)






