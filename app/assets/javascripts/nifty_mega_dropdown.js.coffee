ready = ->
  console.log 'MEGA DROPDOWN'

  megadropdown = null

  mega = (el) ->
    megaBtn = el.find('.mega-dropdown-toggle')
    megaMenu = el.find('.mega-dropdown-menu')
    megaBtn.on 'click', (e) ->
      e.preventDefault()
      el.toggleClass 'open'
      return
    return

  methods =
    toggle: ->
      @toggleClass 'open'
      null
    show: ->
      @addClass 'open'
      null
    hide: ->
      @removeClass 'open'
      null

  $.fn.niftyMega = (method) ->
    chk = false
    @each ->
      if methods[method]
        chk = methods[method].apply($(this).find('input'), Array::slice.call(arguments, 1))
      else if typeof method == 'object' or !method
        mega $(this)
      return
    chk

  nifty.window.on 'load', ->
    megadropdown = $('.mega-dropdown')
    if megadropdown.length
      megadropdown.niftyMega()
    $('html').on 'click', (e) ->
      if megadropdown.length
        if !$(e.target).closest('.mega-dropdown').length
          megadropdown.removeClass 'open'
      return
    return





$(document).ready(ready)