ready = ->
  $(".select2").select2()
  $('a[rel~="tooltip"]').tooltip()
  DependentFields.bind()



$(document).ready(ready)
$(document).on('page:load', ready)
$(document).on('show.bs.modal', ready)