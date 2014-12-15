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


  Pusher.host    = gon.pusher_host
  Pusher.ws_port = 8080
  Pusher.wss_port = 8080

  pusher = new Pusher(gon.pusher_key)

  for register_id in gon.register_ids

    channel = pusher.subscribe("register_#{register_id}")
    console.log "subscribed to channel register_#{register_id}"

    channel.bind "new_reading", (reading) ->
      $("#ticker_#{reading.register_id}").html reading.watt_hour


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