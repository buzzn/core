ready = ->
  console.log 'NIFTY INIT'

  enquire.register 'screen and (max-width: 1200px)',
    deferSetup: true
    match: ->
      $( "#container" ).removeClass( "mainnav-lg" ).addClass( "mainnav-sm" );
    unmatch: ->
      $( "#container" ).removeClass( "mainnav-sm" ).addClass( "mainnav-lg" );

  window.nifty =
    'container': $('#container')
    'contentContainer': $('#content-container')
    'navbar': $('#navbar')
    'mainNav': $('#mainnav-container')
    'aside': $('#aside-container')
    'footer': $('#footer')
    'scrollTop': $('#scroll-top')
    'window': $(window)
    'body': $('body')
    'bodyHtml': $('body, html')
    'document': $(document)
    'screenSize': ''
    'isMobile': do ->
      /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test navigator.userAgent
    'randomInt': (min, max) ->
      Math.floor Math.random() * (max - min + 1) + min
    'transition': do ->
      thisBody = document.body or document.documentElement
      thisStyle = thisBody.style
      support = thisStyle.transition != undefined or thisStyle.WebkitTransition != undefined
      support

  nifty.window.on 'load', ->

    #Activate the Bootstrap tooltips
    tooltip = $('.add-tooltip')
    if tooltip.length
      tooltip.tooltip()
    popover = $('.add-popover')
    if popover.length
      popover.popover()





  nifty.body.addClass 'nifty-ready'

$(document).ready(ready)
