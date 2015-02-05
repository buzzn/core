ready = ->
  console.log 'NOTIFICATION'

  pageHolder = undefined
  floatContainer = {}
  notyContainer = undefined
  addNew = false

  $.niftyNoty = (options) ->
    defaults =
      type: 'primary'
      icon: ''
      title: ''
      message: ''
      closeBtn: true
      container: 'page'
      floating:
        position: 'top-right'
        animationIn: 'jellyIn'
        animationOut: 'fadeOut'
      html: null
      focus: true
      timer: 0
    opt = $.extend({}, defaults, options)
    el = $('<div class="alert-wrap"></div>')

    iconTemplate = ->
      icon = ''
      if options and options.icon
        icon = '<div class="media-left"><span class="icon-wrap icon-wrap-xs icon-circle alert-icon"><i class="' + opt.icon + '"></i></span></div>'
      icon

    alertTimer = undefined
    template = do ->
      clsBtn = if opt.closeBtn then '<button class="close" type="button"><i class="fa fa-times-circle"></i></button>' else ''
      defTemplate = '<div class="alert alert-' + opt.type + '" role="alert">' + clsBtn + '<div class="media">'
      if !opt.html
        return defTemplate + iconTemplate() + '<div class="media-body"><h4 class="alert-title">' + opt.title + '</h4><p class="alert-message">' + opt.message + '</p></div></div>'
      defTemplate + opt.html + '</div></div>'

    closeAlert = (e) ->
      if opt.container == 'floating' and opt.floating.animationOut
        el.removeClass(opt.floating.animationIn).addClass opt.floating.animationOut
        if !nifty.transition
          el.remove()
      el.removeClass('in').on 'transitionend webkitTransitionEnd oTransitionEnd MSTransitionEnd', (e) ->
        if e.originalEvent.propertyName == 'max-height'
          el.remove()
        return
      clearInterval alertTimer
      null

    focusElement = (pos) ->
      nifty.bodyHtml.animate { scrollTop: pos }, 300, ->
        el.addClass 'in'
        return
      return

    init = do ->
      if opt.container == 'page'
        if !pageHolder
          pageHolder = $('<div id="page-alert"></div>')
          nifty.contentContainer.prepend pageHolder
        notyContainer = pageHolder
        if opt.focus
          focusElement 0
      else if opt.container == 'floating'
        if !floatContainer[opt.floating.position]
          floatContainer[opt.floating.position] = $('<div id="floating-' + opt.floating.position + '" class="floating-container"></div>')
          nifty.container.append floatContainer[opt.floating.position]
        notyContainer = floatContainer[opt.floating.position]
        if opt.floating.animationIn
          el.addClass 'in animated ' + opt.floating.animationIn
        opt.focus = false
      else
        $ct = $(opt.container)
        $panelct = $ct.children('.panel-alert')
        $panelhd = $ct.children('.panel-heading')
        if !$ct.length
          addNew = false
          return false
        if !$panelct.length
          notyContainer = $('<div class="panel-alert"></div>')
          if $panelhd.length
            $panelhd.after notyContainer
          else
            $ct.prepend notyContainer
        else
          notyContainer = $panelct
        if opt.focus
          focusElement $ct.offset().top - 30
      addNew = true
      false
    if addNew
      notyContainer.append el.html(template)
      el.find('[data-dismiss="noty"]').one 'click', closeAlert
      if opt.closeBtn
        el.find('.close').one 'click', closeAlert
      if opt.timer > 0
        alertTimer = setInterval(closeAlert, opt.timer)
      if !opt.focus
        addIn = setInterval((->
          el.addClass 'in'
          clearInterval addIn
          return
        ), 200)
    return






$(document).ready(ready)




