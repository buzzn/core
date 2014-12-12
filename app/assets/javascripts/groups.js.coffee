$(".groups.show").ready ->
  $("#mytab a").click (e) ->
    e.preventDefault()
    $(this).tab "show"

  # Javascript to enable link to tab
  hash = document.location.hash
  $(".nav-pills a[href=" + hash + "]").tab "show"  if hash

  # Change hash for page-reload
  $(".nav-pills a").on "shown.bs.tab", (e) ->
    window.location.hash = e.target.hash
    return

  pusher = new Pusher("83f4f88842ce2dc76b7b")

  for metering_point_id in gon.metering_point_ids

    channel = pusher.subscribe("reading_#{metering_point_id}")
    console.log "subscribed to channel reading_#{metering_point_id}"

    channel.bind "new_reading", (reading) ->
      $("#ticker_#{reading.metering_point_id}").html reading.watt_hour


jQuery ->
  # Create a comment
  $(".comment-form")
    .on "ajax:beforeSend", (evt, xhr, settings) ->
      $(this).find('textarea')
        .addClass('uneditable-input')
        .attr('disabled', 'disabled');
    .on "ajax:success", (evt, data, status, xhr) ->
      $(this).find('textarea')
        .removeClass('uneditable-input')
        .removeAttr('disabled', 'disabled')
        .val('');
    .on "ajax:error", (evt, data, status, xhr) ->
      $(this).find('textarea')
        .removeClass('uneditable-input')
        .removeAttr('disabled', 'disabled');

  # Delete a comment
  $(document)
    .on "ajax:beforeSend", ".comment", ->
      $(this).fadeTo('fast', 0.5)
    .on "ajax:success", ".comment", ->
      $(this).hide('fast')
    .on "ajax:error", ".comment", ->
      $(this).fadeTo('fast', 1)