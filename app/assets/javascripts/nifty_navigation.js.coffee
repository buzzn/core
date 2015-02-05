ready = ->
  console.log 'NAVIGATION'

  $menulink = $('#mainnav-menu > li > a, #mainnav-menu-wrap .mainnav-widget a[data-toggle="menu-widget"]')
  mainNavHeight = $('#mainnav').height()
  scrollbar = null
  updateMethod = false
  isSmallNav = false
  screenCat = null
  defaultSize = null

  bindSmallNav = ->
    hidePopover = undefined
    $menulink.each ->
      $el = $(this)
      $listTitle = $el.children('.menu-title')
      $listSub = $el.siblings('.collapse')
      $listWidget = $($el.attr('data-target'))
      $listWidgetParent = if $listWidget.length then $listWidget.parent() else null
      $popover = null
      $poptitle = null
      $popcontent = null
      $popoverSub = null
      popoverPosBottom = 0
      popoverCssBottom = 0
      elPadding = $el.outerHeight() - $el.height() / 4
      listSubScroll = false
      elHasSub = do ->
        if $listWidget.length
          $el.on 'click', (e) ->
            e.preventDefault()
            return
        if $listSub.length
          #$listSub.removeClass('in').removeAttr('style');
          $el.on('click', (e) ->
            e.preventDefault()
            return
          ).parent('li').removeClass 'active'
          true
        else
          false
      updateScrollInterval = null

      updateScrollBar = (el) ->
        clearInterval updateScrollInterval
        updateScrollInterval = setInterval((->
          el.nanoScroller
            preventPageScrolling: true
            alwaysVisible: true
          clearInterval updateScrollInterval
          return
        ), 700)
        return

      $(document).click (event) ->
        if !$(event.target).closest('#mainnav-container').length
          $el.removeClass('hover').popover 'hide'
        return
      $('#mainnav-menu-wrap > .nano').on 'update', (event, values) ->
        $el.removeClass('hover').popover 'hide'
        return
      $el.popover(
        animation: false
        trigger: 'manual'
        container: '#mainnav'
        viewport: $el
        html: true
        title: ->
          if elHasSub
            return $listTitle.html()
          null
        content: ->
          $content = undefined
          if elHasSub
            $content = $('<div class="sub-menu"></div>')
            $listSub.addClass('pop-in').wrap('<div class="nano-content"></div>').parent().appendTo $content
          else if $listWidget.length
            $content = $('<div class="sidebar-widget-popover"></div>')
            $listWidget.wrap('<div class="nano-content"></div>').parent().appendTo $content
          else
            $content = '<span class="single-content">' + $listTitle.html() + '</span>'
          $content
        template: '<div class="popover menu-popover"><h4 class="popover-title"></h4><div class="popover-content"></div></div>').on('show.bs.popover', ->
        if !$popover
          $popover = $el.data('bs.popover').tip()
          $poptitle = $popover.find('.popover-title')
          $popcontent = $popover.children('.popover-content')
          if !elHasSub and $listWidget.length == 0
            return
          $popoverSub = $popcontent.children('.sub-menu')
        if !elHasSub and $listWidget.length == 0
          return
        return
      ).on('shown.bs.popover', ->
        if !elHasSub and $listWidget.length == 0
          margintop = 0 - 0.5 * $el.outerHeight()
          $popcontent.css
            'margin-top': margintop + 'px'
            'width': 'auto'
          return
        offsetTop = parseInt($popover.css('top'))
        elHeight = $el.outerHeight()
        offsetBottom = do ->
          if nifty.container.hasClass('mainnav-fixed')
            $(window).outerHeight() - offsetTop - elHeight
          else
            $(document).height() - offsetTop - elHeight
        popoverHeight = $popcontent.find('.nano-content').children().css('height', 'auto').outerHeight()
        $popcontent.find('.nano-content').children().css 'height', ''
        if offsetTop > offsetBottom
          if $poptitle.length and !$poptitle.is(':visible')
            elHeight = Math.round(0 - 0.5 * elHeight)
          offsetTop -= 5
          $popcontent.css(
            'top': ''
            'bottom': elHeight + 'px'
            'height': offsetTop).children().addClass('nano').css('width': '100%').nanoScroller preventPageScrolling: true
          updateScrollBar $popcontent.find('.nano')
        else
          if !nifty.container.hasClass('navbar-fixed') and nifty.mainNav.hasClass('affix-top')
            offsetBottom -= 50
          if popoverHeight > offsetBottom
            if nifty.container.hasClass('navbar-fixed') or nifty.mainNav.hasClass('affix-top')
              offsetBottom -= elHeight + 5
            offsetBottom -= 5
            $popcontent.css(
              'top': elHeight + 'px'
              'bottom': ''
              'height': offsetBottom).children().addClass('nano').css('width': '100%').nanoScroller preventPageScrolling: true
            updateScrollBar $popcontent.find('.nano')
          else
            if $poptitle.length and !$poptitle.is(':visible')
              elHeight = Math.round(0 - 0.5 * elHeight)
            $popcontent.css
              'top': elHeight + 'px'
              'bottom': ''
              'height': 'auto'
        if $poptitle.length
          $poptitle.css 'height', $el.outerHeight()
        $popcontent.on 'click', ->
          $popcontent.find('.nano-pane').hide()
          updateScrollBar $popcontent.find('.nano')
          return
        return
      ).on('hidden.bs.popover', ->
        # detach from popover, fire event then clean up data
        $el.removeClass 'hover'
        if elHasSub
          $listSub.removeAttr('style').appendTo $el.parent()
        else if $listWidget.length
          $listWidget.appendTo $listWidgetParent
        clearInterval hidePopover
        return
      ).on('click', ->
        if !nifty.container.hasClass('mainnav-sm')
          return
        $menulink.popover 'hide'
        $el.addClass('hover').popover 'show'
        return
      ).hover (->
        $menulink.popover 'hide'
        $el.addClass('hover').popover 'show'
        return
      ), ->
        clearInterval hidePopover
        hidePopover = setInterval((->
          if $popover
            $popover.one 'mouseleave', ->
              $el.removeClass('hover').popover 'hide'
              return
            if !$popover.is(':hover')
              $el.removeClass('hover').popover 'hide'
          clearInterval hidePopover
          return
        ), 500)
        return
      return
    isSmallNav = true
    return

  unbindSmallNav = ->
    colapsed = $('#mainnav-menu').find('.collapse')
    if colapsed.length
      colapsed.each ->
        cl = $(this)
        if cl.hasClass('in')
          cl.parent('li').addClass 'active'
        else
          cl.parent('li').removeClass 'active'
        return
    if scrollbar != null and scrollbar.length
      scrollbar.nanoScroller stop: true
    $menulink.popover('destroy').unbind 'mouseenter mouseleave'
    isSmallNav = false
    return

  updateSize = ->
    #if(!defaultSize) return;
    sw = nifty.container.width()
    currentScreen = undefined
    if sw <= 740
      currentScreen = 'xs'
    else if sw > 740 and sw < 992
      currentScreen = 'sm'
    else if sw >= 992 and sw <= 1200
      currentScreen = 'md'
    else
      currentScreen = 'lg'
    if screenCat != currentScreen
      screenCat = currentScreen
      nifty.screenSize = currentScreen
      if nifty.screenSize == 'sm' and nifty.container.hasClass('mainnav-lg')
        $.niftyNav 'collapse'
    return

  updateNav = (e) ->
    nifty.mainNav.niftyAffix 'update'
    unbindSmallNav()
    updateSize()
    if updateMethod == 'collapse' or nifty.container.hasClass('mainnav-sm')
      nifty.container.removeClass 'mainnav-in mainnav-out mainnav-lg'
      bindSmallNav()
    mainNavHeight = $('#mainnav').height()
    updateMethod = false
    null

  init = ->
    if !defaultSize
      defaultSize =
        xs: 'mainnav-out'
        sm: nifty.mainNav.data('sm') or nifty.mainNav.data('all')
        md: nifty.mainNav.data('md') or nifty.mainNav.data('all')
        lg: nifty.mainNav.data('lg') or nifty.mainNav.data('all')
      hasData = false
      for item of defaultSize
        if defaultSize[item]
          hasData = true
          break
      if !hasData
        defaultSize = null
      updateSize()
    return

  methods =
    'revealToggle': ->
      if !nifty.container.hasClass('reveal')
        nifty.container.addClass 'reveal'
      nifty.container.toggleClass('mainnav-in mainnav-out').removeClass 'mainnav-lg mainnav-sm'
      if isSmallNav
        unbindSmallNav()
      return
    'revealIn': ->
      if !nifty.container.hasClass('reveal')
        nifty.container.addClass 'reveal'
      nifty.container.addClass('mainnav-in').removeClass 'mainnav-out mainnav-lg mainnav-sm'
      if isSmallNav
        unbindSmallNav()
      return
    'revealOut': ->
      if !nifty.container.hasClass('reveal')
        nifty.container.addClass 'reveal'
      nifty.container.removeClass('mainnav-in mainnav-lg mainnav-sm').addClass 'mainnav-out'
      if isSmallNav
        unbindSmallNav()
      return
    'slideToggle': ->
      if !nifty.container.hasClass('slide')
        nifty.container.addClass 'slide'
      nifty.container.toggleClass('mainnav-in mainnav-out').removeClass 'mainnav-lg mainnav-sm'
      if isSmallNav
        unbindSmallNav()
      return
    'slideIn': ->
      if !nifty.container.hasClass('slide')
        nifty.container.addClass 'slide'
      nifty.container.addClass('mainnav-in').removeClass 'mainnav-out mainnav-lg mainnav-sm'
      if isSmallNav
        unbindSmallNav()
      return
    'slideOut': ->
      if !nifty.container.hasClass('slide')
        nifty.container.addClass 'slide'
      nifty.container.removeClass('mainnav-in mainnav-lg mainnav-sm').addClass 'mainnav-out'
      if isSmallNav
        unbindSmallNav()
      return
    'pushToggle': ->
      nifty.container.toggleClass('mainnav-in mainnav-out').removeClass 'mainnav-lg mainnav-sm'
      if nifty.container.hasClass('mainnav-in mainnav-out')
        nifty.container.removeClass 'mainnav-in'
      #if (nifty.container.hasClass('mainnav-in')) //nifty.container.removeClass('aside-in');
      if isSmallNav
        unbindSmallNav()
      return
    'pushIn': ->
      nifty.container.addClass('mainnav-in').removeClass 'mainnav-out mainnav-lg mainnav-sm'
      if isSmallNav
        unbindSmallNav()
      return
    'pushOut': ->
      nifty.container.removeClass('mainnav-in mainnav-lg mainnav-sm').addClass 'mainnav-out'
      if isSmallNav
        unbindSmallNav()
      return
    'colExpToggle': ->
      if nifty.container.hasClass('mainnav-lg mainnav-sm')
        nifty.container.removeClass 'mainnav-lg'
      nifty.container.toggleClass('mainnav-lg mainnav-sm').removeClass 'mainnav-in mainnav-out'
      nifty.window.trigger 'resize'
    'collapse': ->
      nifty.container.addClass('mainnav-sm').removeClass 'mainnav-lg mainnav-in mainnav-out'
      updateMethod = 'collapse'
      nifty.window.trigger 'resize'
    'expand': ->
      nifty.container.removeClass('mainnav-sm mainnav-in mainnav-out').addClass 'mainnav-lg'
      nifty.window.trigger 'resize'
    'togglePosition': ->
      nifty.container.toggleClass 'mainnav-fixed'
      nifty.mainNav.niftyAffix 'update'
      return
    'fixedPosition': ->
      nifty.container.addClass 'mainnav-fixed'
      nifty.mainNav.niftyAffix 'update'
      return
    'staticPosition': ->
      nifty.container.removeClass 'mainnav-fixed'
      nifty.mainNav.niftyAffix 'update'
      return
    'update': updateNav
    'forceUpdate': updateSize
    'getScreenSize': ->
      screenCat

  $.niftyNav = (method, complete) ->
    if methods[method]
      if method == 'colExpToggle' or method == 'expand' or method == 'collapse'
        if nifty.screenSize == 'xs' and method == 'collapse'
          method = 'pushOut'
        else if (nifty.screenSize == 'xs' or nifty.screenSize == 'sm') and (method == 'colExpToggle' or method == 'expand') and nifty.container.hasClass('mainnav-sm')
          method = 'pushIn'
      val = methods[method].apply(this, Array::slice.call(arguments, 1))
      if complete
        return complete()
      else if val
        return val
    null

  $.fn.isOnScreen = ->
    viewport =
      top: nifty.window.scrollTop()
      left: nifty.window.scrollLeft()
    viewport.right = viewport.left + nifty.window.width()
    viewport.bottom = viewport.top + nifty.window.height()
    bounds = @offset()
    bounds.right = bounds.left + @outerWidth()
    bounds.bottom = bounds.top + @outerHeight()
    !(viewport.right < bounds.left or viewport.left > bounds.right or viewport.bottom < bounds.bottom or viewport.top > bounds.top)



  shortcutBtn = $('#mainnav-shortcut')
  if shortcutBtn.length
    shortcutBtn.find('li').each ->
      $el = $(this)
      $el.popover
        animation: false
        trigger: 'hover focus'
        placement: 'bottom'
        container: '#mainnav-container'
        template: '<div class="popover mainnav-shortcut"><div class="arrow"></div><div class="popover-content"></div>'





  nifty.window.on('resizeEnd', updateNav).trigger 'resize'

  toggleBtn = $('.mainnav-toggle')
  if toggleBtn.length
    toggleBtn.on 'click', (e) ->
      e.preventDefault()
      if toggleBtn.hasClass('push')
        $.niftyNav 'pushToggle'
      else if toggleBtn.hasClass('slide')
        $.niftyNav 'slideToggle'
      else if toggleBtn.hasClass('reveal')
        $.niftyNav 'revealToggle'
      else
        $.niftyNav 'colExpToggle'
      return
  menu = $('#mainnav-menu')
  if menu.length
    # COLLAPSIBLE MENU LIST
    # =================================================================
    # Require MetisMenu
    # http://demo.onokumus.com/metisMenu/
    # =================================================================
    $('#mainnav-menu').metisMenu toggle: true
    # STYLEABLE SCROLLBARS
    # =================================================================
    # Require nanoScroller
    # http://jamesflorentino.github.io/nanoScrollerJS/
    # =================================================================
    scrollbar = nifty.mainNav.find('.nano')
    if scrollbar.length
      scrollbar.nanoScroller preventPageScrolling: true
  return






$(document).ready(ready)
