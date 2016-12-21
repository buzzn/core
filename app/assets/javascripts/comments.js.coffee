$(".comments-panel").ready ->
  commentable_id = $(this).attr('data-commentable-id')
  commentable_type = $(this).attr('data-commentable-type')

  #Pusher.host    = gon.global.pusher_host
  #Pusher.ws_port = gon.global.pusher_ws_port
  #Pusher.wss_port = gon.global.pusher_wss_port


  if $(this).find('.comments-content').length > 0
    pusher = new Pusher(gon.global.pusher_key)

    channel = pusher.subscribe("#{commentable_type}_#{commentable_id}")
    $(".comment-form").each ->
      $(this).on "ajax:beforeSend", (evt, xhr, settings) ->
        settings.data += '&socket_id=' + pusher.connection.socket_id
    channel.bind "new_comment", (comment) ->
      html = comment.html
      destination = ""
      if comment.root_type == "PublicActivity::ORM::ActiveRecord::Activity"
        destination = "#activity_#{comment.root_id}"
        $(destination).find(".child-comments").append(html).hide().show('slow');
      else if comment.root_type == "Comment"
        destination = "#comment_#{comment.root_id}"
        $(destination).find(".child-comments").append(html).hide().show('slow');
      else if comment.root_type == "Conversation"
        destination = "#conversation_#{comment.root_id}_comments-all"
        $(destination).prepend(html).hide().show('slow');
      else
        destination = ".comments-all"
        $(destination).prepend(html).hide().show('slow');

      that = $("#comment_#{comment.id}")
      that.find('time[data-time-ago]').timeago()

      that.find(".vote-for").on "click", ->
        $.ajax({url: '/comments/' + comment.id + '/voted', dataType: 'json'})
          .success (data) ->
            that.find(".likes").first().find(".likes-count").html(data.likes)
            if data.liked_by_current_user
              that.find(".likes").first().find(".vote-icon").removeClass("fa-heart-o").addClass("fa-heart")
            else
              that.find(".likes").first().find(".vote-icon").removeClass("fa-heart").addClass("fa-heart-o")
            that.find(".likes").first().attr('data-original-title', data.voters + ' ' + "<span><div class='fa fa-heart'></div></span>" + ' ' + data.i18n_this_comment)


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

      that.find('.set-chart-view').on 'click', ->
        timestamp = $(this).data('timestamp')
        resolution = $(this).data('resolution')
        type = $(this).data('commentable-type')
        id = $(this).data('commentable-id')
        Chart.Functions.setResolution(resolution)
        Chart.Functions.showLoadingBlockButtons()
        if type == 'Register::Base'
          type = 'registers'
          Chart.Functions.setChartData(type, id, timestamp)
          $('html, body').animate({ scrollTop: $('.register_detail').offset().top}, 1000)
        else if type == 'Group'
          type = 'groups'
          Chart.Functions.setChartDataMultiSeries(type, id, timestamp)
          $('html, body').animate({ scrollTop: $('.group-chart').offset().top}, 1000)

      $(".likes").tooltip({html: true})

      Chart.Functions.refreshChartComments()

    channel.bind "likes_changed", (data) ->
      if pusher.connection.socket_id != data.socket_id
        $("##{data.div}").find(".likes").first().find(".likes-count").html(data.likes)
        $("##{data.div}").find(".likes").first().attr('data-original-title', data.voters + ' ' + "<span><div class='fa fa-heart'></div></span>" + ' ' + data.i18n_this_comment)


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
    that.find(".likes").first().find(".vote-for").on "click", ->
      $.ajax({url: '/comments/' + comment_id + '/voted', dataType: 'json'})
        .success (data) ->
          that.find(".likes").first().find(".likes-count").html(data.likes)
          if data.liked_by_current_user
            that.find(".likes").first().find(".vote-icon").removeClass("fa-heart-o").addClass("fa-heart")
          else
            that.find(".likes").first().find(".vote-icon").removeClass("fa-heart").addClass("fa-heart-o")
          that.find(".likes").first().attr('data-original-title', data.voters + ' ' + "<span><div class='fa fa-heart'></div></span>" + ' ' + data.i18n_this_comment)

    that.find(".comment-reply").on "click", ->
      if that.find(".comment-answer").css("display") == "none"
        that.find(".comment-answer").css("display", "block")
      else
        that.find(".comment-answer").css("display", "none")
    that.find(".comment-view-all-answers").on "click", ->
      that.find(".child-comments").find(".comment").each ->
        $(this).show()
      that.find(".comment-view-all-answers").hide()
    that.find('.set-chart-view').on 'click', ->
      timestamp = $(this).data('timestamp')
      resolution = $(this).data('resolution')
      type = $(this).data('commentable-type')
      id = $(this).data('commentable-id')
      Chart.Functions.setResolution(resolution)
      Chart.Functions.showLoadingBlockButtons()
      if type == 'Register::Base'
        type = 'registers'
        Chart.Functions.setChartData(type, id, timestamp)
        $('html, body').animate({ scrollTop: $('.register_detail').offset().top}, 1000)
      else if type == 'Group'
        type = 'groups'
        Chart.Functions.setChartDataMultiSeries(type, id, timestamp)
        $('html, body').animate({ scrollTop: $('.group-chart').offset().top}, 1000)



  $(this).find(".activity").each ->
    activity_id = $(this).attr('id').split('_')[1]
    that = $(this)
    that.find(".likes").first().find(".vote-for").on "click", ->
      $.ajax({url: '/activities/' + activity_id + '/voted', dataType: 'json'})
        .success (data) ->
          that.find(".likes").first().find(".likes-count").html(data.likes)
          if data.liked_by_current_user
            that.find(".likes").first().find(".vote-icon").removeClass("fa-heart-o").addClass("fa-heart")
          else
            that.find(".likes").first().find(".vote-icon").removeClass("fa-heart").addClass("fa-heart-o")
          that.find(".likes").first().attr('data-original-title', data.voters + ' ' + "<span><div class='fa fa-heart'></div></span>" + ' ' + data.i18n_this_comment)

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
      $('.chart-comment-form').css('display', 'none')

    $(this).on "ajax:error", (evt, data, status, xhr) ->
      $(this).find('textarea')
        .removeClass('uneditable-input')
        .removeAttr('disabled', 'disabled')