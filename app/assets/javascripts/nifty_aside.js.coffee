ready = ->
  console.log 'ASIDE'

  asideMethods =
    'toggleHideShow': ->
      nifty.container.toggleClass 'aside-in'
      nifty.window.trigger 'resize'
      if nifty.container.hasClass('aside-in')
        toggleNav()
      return
    'show': ->
      nifty.container.addClass 'aside-in'
      nifty.window.trigger 'resize'
      toggleNav()
      return
    'hide': ->
      nifty.container.removeClass 'aside-in'
      nifty.window.trigger 'resize'
      return
    'toggleAlign': ->
      nifty.container.toggleClass 'aside-left'
      nifty.aside.niftyAffix 'update'
      return
    'alignLeft': ->
      nifty.container.addClass 'aside-left'
      nifty.aside.niftyAffix 'update'
      return
    'alignRight': ->
      nifty.container.removeClass 'aside-left'
      nifty.aside.niftyAffix 'update'
      return
    'togglePosition': ->
      nifty.container.toggleClass 'aside-fixed'
      nifty.aside.niftyAffix 'update'
      return
    'fixedPosition': ->
      nifty.container.addClass 'aside-fixed'
      nifty.aside.niftyAffix 'update'
      return
    'staticPosition': ->
      nifty.container.removeClass 'aside-fixed'
      nifty.aside.niftyAffix 'update'
      return
    'toggleTheme': ->
      nifty.container.toggleClass 'aside-bright'
      return
    'brightTheme': ->
      nifty.container.addClass 'aside-bright'
      return
    'darkTheme': ->
      nifty.container.removeClass 'aside-bright'
      return

  toggleNav = ->
    if nifty.container.hasClass('mainnav-in') and nifty.screenSize != 'xs'
      if nifty.screenSize == 'sm'
        $.niftyNav 'collapse'
      else
        nifty.container.removeClass('mainnav-in mainnav-lg mainnav-sm').addClass 'mainnav-out'
    return

  $.niftyAside = (method, complete) ->
    if asideMethods[method]
      asideMethods[method].apply this, Array::slice.call(arguments, 1)
      if complete
        return complete()
    null




$(document).ready(ready)


