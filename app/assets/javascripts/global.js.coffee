ready = ->
  $(".select2").select2()
  $('a[rel~="tooltip"]').tooltip();

$(document).ready(ready)
$(document).on('page:load', ready)
DependentFields.bind()

