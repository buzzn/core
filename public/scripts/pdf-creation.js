Function.prototype.bind = Function.prototype.bind || function (thisp) {
    var fn = this;
    return function () {
        return fn.apply(thisp, arguments);
    };
};

// test navigator.userAgent for PDF creator's headless browser
function isQt() {
  return /Qt/.test(navigator.userAgent);
}

// function fixPdfDimensions()
function fixPdfDimensions() {
  var fontSize = isQt() ? '72px' : '16pt';
  var wrapperHeight = isQt() ? '4000px' : '1000px';
  $('html').css('font-size', fontSize);
  $('.wrapper').css('min-height', wrapperHeight);
}

// function setPageBreaks()
// @param {String} footer - HTML
function setPageBreaks(footer){
  footer = footer || '<footer><p class="pagination is-small">Seite <span class="page-number">#</span> von <span class="page-total-number">#</span></p></footer>'
  var pageSplitThreshold = isQt() ? 2000 : 1000;
  var pages = '';
  var pageCount;
  $('.wrapper').each(function(){
    var self = $(this);
    var isTall = isQt() ? self.hasClass('breakable') && self.height() > pageSplitThreshold : self.height() > pageSplitThreshold;
    var wrapperTop = self.offset().top;
    if (isTall) {
      var normalChildren = self.children().filter(function(){var applies = $(this).offset().top + $(this).outerHeight() < wrapperTop + pageSplitThreshold; return applies});
      var oversetChildren = self.children().filter(function(){var applies = $(this).offset().top + $(this).outerHeight() >= wrapperTop + pageSplitThreshold; return applies});
      // debug
      // normalChildren.css('border','1px solid lime');
      // oversetChildren.css({'border':'1px solid magenta'});
      pages += '<div class="wrapper">';
      // debug
      // pages += '<div class="log mint">' + isTall + ' ' + self.height() +'px </div>';
      pages += normalChildren.toArray().reduce(function(a,e){return a+e.outerHTML}, '') + footer;
      pages += '</div>';
      pages += '<div class="alwaysbreak"></div>';
      pages += '<div class="wrapper">';
      // debug
      // pages += '<div class="log pork">' + isTall + ' ' + self.height() +'px </div>';
      pages += oversetChildren.toArray().reduce(function(a,e){return a+e.outerHTML}, '') + footer ;
      pages += '</div>';
      pages += '<div class="alwaysbreak"></div>';
    } else {
      pages += '<div class="wrapper">';
      // debug
      // pages += '<div class="log mint">' + isTall + ' ' + self.height() +'px </div>';
      pages += self.html() + footer;
      pages += '</div>';
      pages += '<div class="alwaysbreak"></div>';
    }
  });
  $('body').html(pages);
  var pagination = $('.pagination');
  pageCount = pagination.toArray().length;
  pagination.find('.page-total-number').html(pageCount);
  pagination.each(function(i){$(this).find('.page-number').html(i+1)})
  // debug
  // $('p, ul').each(function(){$(this).css('position','relative').html($(this).html()+'<div class="log mint">' + $(this).height() +'px </div>')});
  // $('h2, h3, h4, td').each(function(){$(this).css('position','relative').html($(this).html()+'<div class="log pork">' + $(this).height() +'px </div>')});
}
