// function bcChart()
// @param {String} id the CSS selector
// @param {Array} [labels] list of String labels
// @param {Array} [data] a list of Numeric or String numbers
// @param {String} title the title of the chart, optional
function bcChart (id, labels, data, title) {
  var chart = $(id);
  var chartContainer = $(id + ' .bc-chart-container');
  var isHorizontal = chart.hasClass('horizontal');
  var legendContainer = !isHorizontal ? $(id + ' .bc-legend-container') : null;
  var colors = ['#999', '#aaa', '#bbb', '#ccc', '#ddd', '#eee'];
  var data = data.map(function(e){return parseFloat(e)})
  // calculate horizontal/vertical bar length
  var sum = data.reduce(function(a,b){return a+b});
  var maxvalue = data.reduce(function(a,b){return Math.max(a,b)});
  var barLength = data.map(function(e){return(e/maxvalue)*100});
  var barHeight = data.map(function(e){return e/sum*$('#chart-two').height()});
  // calculate tick positions
  var ticks = [0,1,2,3,4,5].map(function(e,i,arr){return Math.round((maxvalue/(arr.length-1))*e);});
  // create child elements
  var barsHtml = !isHorizontal ? data.reduce(function(a,e){return a + '<div class="bc-bar"></div>'},'') : data.reduce(function(a,e){return a + '<div><div class="bc-label is-inline-block">label</div><div class="bc-bar is-inline-block"></div><div class="bc-value is-inline-block">value</div></div>'},'');
  barsHtml += data.reduce(function(a,e){return a + '<div class="bc-tick"></div>'},'<div class="bc-tick-container"><div class="bc-tick"></div>');
  barsHtml += '</div>'
  barsHtml += title ? '<h4>'+title+'</h4>':'';
  var legendHtml = data.reduce(function(a,e,i){
    return a + '<p class="bc-legend"><span class="bc-legend-indicator"></span>' + labels[i]+': '+((e/sum)*100).toFixed(1)+' %</p>';
  }, '')
  // Workaround: add child elements as html to chartContainer as chartContainer.addChild() won't work (https://github.com/wkhtmltopdf/wkhtmltopdf/issues/3731)
  chartContainer.html(barsHtml);
  if(isHorizontal) {
    chartContainer.find('.bc-bar').each(function(i){
      var html = labels[i]+': <span>'+data[i]+' kWh</span>';
      var css = {'background-color': colors[i], 'width' : barLength[i]/2+'%'};
      $(this).html('').css(css);
    });
    chartContainer.find('.bc-tick').each(function(i){
      var css = {'left': 100/data.length*i+'%'};
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
      var css = {'left':0, 'top': 100/data.length*i+'%'};
      $(this).css(css);
    });
    legendContainer.html(legendHtml);
    $(id + ' .bc-legend-indicator').each(function(i){$(this).css({'background': colors[i]})});
  }
}
