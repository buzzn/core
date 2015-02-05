ready = ->
  console.log 'AFFIX'

  $.fn.niftyAffix = (method) ->
    @each ->
      el = $(this)
      className = undefined
      if typeof method == 'object' or !method
        className = method.className
        el.data 'nifty.af.class', method.className
      else if method == 'update'
        className = el.data('nifty.af.class')
      if nifty.container.hasClass(className) and !nifty.container.hasClass('navbar-fixed')
        el.affix offset: top: $('#navbar').outerHeight()
      else if !nifty.container.hasClass(className) or nifty.container.hasClass('navbar-fixed')
        nifty.window.off el.attr('id') + '.affix'
        el.removeClass('affix affix-top affix-bottom').removeData 'bs.affix'
      return

  nifty.window.on 'load', ->
    if nifty.mainNav.length
      nifty.mainNav.niftyAffix className: 'mainnav-fixed'
    if nifty.aside.length
      nifty.aside.niftyAffix className: 'aside-fixed'
    return


$(document).ready(ready)