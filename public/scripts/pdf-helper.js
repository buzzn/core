Function.prototype.bind = Function.prototype.bind || function (thisp) {
    var fn = this;
    return function () {
        return fn.apply(thisp, arguments);
    };
};

function bcChart (id, labels, data, title) {
  var chart = $(id);
  var chartContainer = $(id + ' .bc-chart-container');
  var legendContainer = !isHoriz ? $(id + ' .bc-legend-container') : null;
  var isHoriz = chart.hasClass('horizontal');
  var colors = ['#999', '#aaa', '#bbb', '#ccc', '#ddd', '#eee'];
  // calculate horizontal/vertical bar length
  var sum = data.reduce(function(a,b){return a+b});
  var maxvalue = data.reduce(function(a,b){return Math.max(a,b)});
  var barLength = data.map(function(e){return(e/maxvalue)*100});
  var barHeight = data.map(function(e){return e/sum*$('#chart-two').height()});
  // calculate tick positions and values
  var ticks = [0,1,2,3,4,5].map(function(e){return Math.round((maxvalue/5)*e);});
  // create child elements
  var barsHtml = !isHoriz ? data.reduce(function(a,e){return a + '<div class="bc-bar"></div>'},'') : data.reduce(function(a,e){return a + '<div><div class="bc-label is-inline-block">label</div><div class="bc-bar is-inline-block"></div><div class="bc-value is-inline-block">value</div></div>'},'');
  barsHtml += data.reduce(function(a,e){return a + '<div class="bc-tick"></div>'},'<div class="bc-tick-container"><div class="bc-tick"></div>');
  barsHtml += '</div>'
  barsHtml += title ? '<h4>'+title+'</h4>':'';
  var legendHtml = data.reduce(function(a,e,i){
    return a + '<p class="bc-legend"><span class="bc-legend-indicator"></span>' + labels[i]+': '+((e/sum)*100).toFixed(1)+' %</p>';
  }, '')
  // Workaround: add child elements as html to chartContainer as chartContainer.addChild() won't work (https://github.com/wkhtmltopdf/wkhtmltopdf/issues/3731)
  chartContainer.html(barsHtml);
  if(isHoriz) {
    chartContainer.find('.bc-bar').each(function(i){
      var html = labels[i]+': <span>'+data[i]+' kWh</span>';
      var css = {'background-color': colors[i], 'width' : barLength[i]/2+'%'};
      $(this).html('').css(css);
    });
    chartContainer.find('.bc-tick').each(function(i){
      var css = {'left': 20*i+'%'};
      $(this).css(css);
    });
    chartContainer.find('.bc-label').each(function(i){
      var html = labels[i];
      $(this).html(html);
    });
    chartContainer.find('.bc-value').each(function(i){
      var html = '<span>'+data[i]+' kWh</span>';
      $(this).html(html);
    });
  } else {
    chartContainer.children('.bc-bar').each(function(i){
      var css = {'background-color': colors[i], 'height': barHeight[i]+'px'};
      $(this).css(css);
    });
    chartContainer.find('.bc-tick').each(function(i){
      var css = {'left':0, 'top': 20*i+'%'};
      $(this).css(css);
    });
    legendContainer.html(legendHtml);
    $(id + ' .bc-legend-indicator').each(function(i){$(this).css({'background': colors[i]})});
  }
}

function setPageBreaks(footer){
  var isQt = /Qt/.test(navigator.userAgent);
  var pageSplitThreshold = isQt ? 2000 : 1000;
  var pages = '';
  var pageCount;
  $('.wrapper').each(function(){
    var self = $(this);
    var isTall = isQt ? self.hasClass('tall') && self.height() > pageSplitThreshold : self.height() > pageSplitThreshold;
    var wrapperTop = self.offset().top;
    if (isTall) {
      var normalChildren = self.children().filter(function(){var applies = $(this).offset().top + $(this).outerHeight() < wrapperTop + pageSplitThreshold; return applies});
      var oversetChildren = self.children().filter(function(){var applies = $(this).offset().top + $(this).outerHeight() >= wrapperTop + pageSplitThreshold; return applies});
      // normalChildren.css('border','1px solid lime');
      // oversetChildren.css({'border':'1px solid magenta'});
      pages += '<div class="wrapper">';
      // pages += '<div class="log mint">' + isTall + ' ' + self.height() +'px </div>';
      pages += normalChildren.toArray().reduce(function(a,e){return a+e.outerHTML}, '') + footer;
      pages += '</div>';
      pages += '<div class="alwaysbreak"></div>';
      pages += '<div class="wrapper">';
      // pages += '<div class="log pork">' + isTall + ' ' + self.height() +'px </div>';
      pages += oversetChildren.toArray().reduce(function(a,e){return a+e.outerHTML}, '') + footer ;
      pages += '</div>';
      pages += '<div class="alwaysbreak"></div>';
    } else {
      pages += '<div class="wrapper">';
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
