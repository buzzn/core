$(".comments-panel").ready ->
  commentable_id = $(this).attr('data-commentable-id')
  commentable_type = $(this).attr('data-commentable-type')

  #Pusher.host    = gon.global.pusher_host
  #Pusher.ws_port = gon.global.pusher_ws_port
  #Pusher.wss_port = gon.global.pusher_wss_port
  pusher = new Pusher(gon.global.pusher_key)

  channel = pusher.subscribe("#{commentable_type}_#{commentable_id}")
  console.log 'subscribed to ' + commentable_type + '_' + commentable_id
  channel.bind "new_comment", (comment) ->
    console.log 'incoming comment'
    console.log comment
    if pusher.connection.socket_id != comment.socket_id
      html = comment.html
      destination = ""
      if comment.root_type == "PublicActivity::ORM::ActiveRecord::Activity"
        destination = "#activity_#{comment.root_id}"
        $(destination).find(".child-comments").append(html).hide().show('slow');
      else if comment.root_type == "Comment"
        destination = "#comment_#{comment.root_id}"
        $(destination).find(".child-comments").append(html).hide().show('slow');
      else
        destination = ".comments-all"
        $(destination).prepend(html).hide().show('slow');

      that = $("#comment_#{comment.id}")

      that.find(".increase-likes").on "click", ->
        $.ajax({url: '/comments/' + comment.id + '/voted?mode=good', dataType: 'json'})
          .success (data) ->
            that.find(".likes").first().find(".likes-count").html(data.likes)
            that.find(".likes").first().find(".dislikes-count").html(data.dislikes)
      that.find(".increase-dislikes").on "click", ->
        $.ajax({url: '/comments/' + comment.id + '/voted?mode=bad', dataType: 'json'})
          .success (data) ->
            that.find(".likes").first().find(".likes-count").html(data.likes)
            that.find(".likes").first().find(".dislikes-count").html(data.dislikes)
      that.find(".comment-reply").on "click", ->
        if that.find(".comment-answer").css("display") == "none"
          that.find(".comment-answer").css("display", "block")
        else
          that.find(".comment-answer").css("display", "none")

      that.find(".comment-view-all-answers").on "click", ->
        that.find(".child-comments").find(".comment").each ->
          $(this).show()
        that.find(".comment-view-all-answers").hide()

      that.find(".comment-form").find(".comment-form-show-image").on "click", ->
        if that.find(".comment-form-image").css("display") == "none"
          that.find(".comment-form-image").css("display", "block")
          $(".comments-content").css("cssText", "top: 220px !important; right: -14px;")
        else
          that.find(".comment-form-image").css("display", "none")
          $(".comments-content").css("cssText", "top: 143px !important; right: -14px;")

      that.find(".comment-form").on "ajax:beforeSend", (evt, xhr, settings) ->
        settings.data += '&socket_id=' + pusher.connection.socket_id
        $(this).find('textarea')
          .addClass('uneditable-input')
          .attr('disabled', 'disabled')

      that.find(".comment-form").on "ajax:success", (evt, data, status, xhr) ->
        $(this).find('textarea')
          .removeClass('uneditable-input')
          .removeAttr('disabled', 'disabled')
          .val('')
        $(this).find('form').get(0).reset()
        $(this).find('.comment-form-image').css("display", "none")

      that.find(".comment-form").on "ajax:error", (evt, data, status, xhr) ->
        $(this).find('textarea')
          .removeClass('uneditable-input')
          .removeAttr('disabled', 'disabled')


  $(window).on 'beforeunload', ->
    pusher.disconnect()

  $(this).find(".child-comments").each ->
    count_answers = 0
    $(this).find(".comment").each ->
      count_answers += 1
      if count_answers > 2
        $(this).hide()

  $(this).find(".comment").each ->
    comment_id = $(this).attr('id').split('_')[1]
    that = $(this)
    that.find(".increase-likes").on "click", ->
      $.ajax({url: '/comments/' + comment_id + '/voted?mode=good', dataType: 'json'})
        .success (data) ->
          that.find(".likes").first().find(".likes-count").html(data.likes)
          that.find(".likes").first().find(".dislikes-count").html(data.dislikes)
    that.find(".increase-dislikes").on "click", ->
      $.ajax({url: '/comments/' + comment_id + '/voted?mode=bad', dataType: 'json'})
        .success (data) ->
          that.find(".likes").first().find(".likes-count").html(data.likes)
          that.find(".likes").first().find(".dislikes-count").html(data.dislikes)
    that.find(".comment-reply").on "click", ->
      if that.find(".comment-answer").css("display") == "none"
        that.find(".comment-answer").css("display", "block")
      else
        that.find(".comment-answer").css("display", "none")
    that.find(".comment-view-all-answers").on "click", ->
      that.find(".child-comments").find(".comment").each ->
        $(this).show()
      that.find(".comment-view-all-answers").hide()

  $(this).find(".comment-form").each ->
    that = $(this)
    $(this).find(".comment-form-show-image").on "click", ->
      if that.find(".comment-form-image").css("display") == "none"
        that.find(".comment-form-image").css("display", "block")
        $(".comments-content").css("cssText", "top: 220px !important; right: -14px;")
      else
        that.find(".comment-form-image").css("display", "none")
        $(".comments-content").css("cssText", "top: 143px !important; right: -14px;")

    $(this).on "ajax:beforeSend", (evt, xhr, settings) ->
      settings.data += '&socket_id=' + pusher.connection.socket_id
      $(this).find('textarea')
        .addClass('uneditable-input')
        .attr('disabled', 'disabled')

    $(this).on "ajax:success", (evt, data, status, xhr) ->
      $(this).find('textarea')
        .removeClass('uneditable-input')
        .removeAttr('disabled', 'disabled')
        .val('')
      $(this).find('form').get(0).reset()
      $(this).find('.comment-form-image').css("display", "none")

    $(this).on "ajax:error", (evt, data, status, xhr) ->
      $(this).find('textarea')
        .removeClass('uneditable-input')
        .removeAttr('disabled', 'disabled')



  $(this).find(".activity").each ->
    activity_id = $(this).attr('id').split('_')[1]
    that = $(this)
    that.find(".likes").first().find(".increase-likes").on "click", ->
      $.ajax({url: '/activities/' + activity_id + '/voted?mode=good', dataType: 'json'})
        .success (data) ->
          that.find(".likes").first().find(".likes-count").html(data.likes)
          that.find(".likes").first().find(".dislikes-count").html(data.dislikes)
    that.find(".likes").first().find(".increase-dislikes").on "click", ->
      $.ajax({url: '/activities/' + activity_id + '/voted?mode=bad', dataType: 'json'})
        .success (data) ->
          that.find(".likes").first().find(".likes-count").html(data.likes)
          that.find(".likes").first().find(".dislikes-count").html(data.dislikes)
    that.find(".comment-reply").on "click", ->
      if that.find(".comment-answer").css("display") == "none"
        that.find(".comment-answer").css("display", "block")
      else
        that.find(".comment-answer").css("display", "none")
    that.find(".comment-view-all-answers").on "click", ->
      that.find(".child-comments").find(".comment").each ->
        $(this).show()
      that.find(".comment-view-all-answers").hide()