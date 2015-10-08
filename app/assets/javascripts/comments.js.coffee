$(".comments-panel").ready ->
  commentable_id = $(this).attr('data-commentable_id')
  commentable_type = $(this).attr('data-commentable-type')
  # Pusher.host    = $(".pusher").data('pusherhost')
  # Pusher.ws_port = 8080
  # Pusher.wss_port = 8080
  # pusher = new Pusher($(".pusher").data('pusherkey'))

  # channel = pusher.subscribe("Group_#{group_id}")
  # console.log 'subscribed to ' + group_id
  # channel.bind "new_comment", (comment) ->
  #   console.log 'incoming comment'
  #   if pusher.connection.socket_id != comment.socket_id
  #     html = '' +
  #       '<li class="mar-btm comment" id="comment_' + comment.id + '">
  #         <div class="media-left">
  #           <img alt="' + comment.img_alt + '" class="img-circle img-sm" src="' + comment.image + '"/>
  #         </div>
  #         <div class="media-body pad-hor speech-left">
  #           <div class="speech">
  #             <a class="media-heading" href="' + comment.profile_href + '">
  #               ' + comment.user_name + '
  #             </a>
  #             <p>
  #               ' + comment.body + '
  #             </p>
  #             <div class="likes pull-right">
  #               <p class="speech-time">
  #                 <i class="increase-likes fa fa-thumbs-o-up"></i>
  #                 <div class="likes-count">
  #                   <%=' + comment.likes + '%>
  #                 </div>
  #               </p>
  #             </div>
  #             <p class="speech-time time">
  #               <i class="fa fa-clock-o fa-fw"></i>
  #               ' + comment.created_at + '
  #             </p>
  #           </div>
  #         </div>
  #       </li>'
  #     $(".comments-all").append(html).hide().show('slow');
  #     $(".comments-content").animate({
  #       scrollTop: $("#comment_" + comment.id).offset().top
  #     }, 1000)
  #     that = $("#comment_#{coment.id}")
  #     that.find(".increase-likes").on "click", ->
  #       $.ajax({url: '/comments/' + comment_id + '/increase_likes', dataType: 'json'})
  #         .success (data) ->
  #           that.find(".likes-count").html(data.likes)
  #           that.find(".increase-likes").unbind "click"
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
      console.log 'click like'
      $.ajax({url: '/comments/' + comment_id + '/voted?mode=good', dataType: 'json'})
        .success (data) ->
          console.log 'success'
          that.find(".likes").first().find(".likes-count").html(data.likes)
          that.find(".likes").first().find(".dislikes-count").html(data.dislikes)
          #that.find(".likes").first().find(".increase-likes").unbind "click"
    that.find(".increase-dislikes").on "click", ->
      console.log 'click dislike'
      $.ajax({url: '/comments/' + comment_id + '/voted?mode=bad', dataType: 'json'})
        .success (data) ->
          console.log 'success'
          that.find(".likes").first().find(".likes-count").html(data.likes)
          that.find(".likes").first().find(".dislikes-count").html(data.dislikes)
          #that.find(".likes").first().find(".increase-dislikes").unbind "click"
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
      #settings.data += '&socket_id=' + pusher.connection.socket_id
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