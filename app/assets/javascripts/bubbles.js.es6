$('.bubbles_container').ready(function bubblesContainerReady() {
  const bubblesTimers = {
    fetchTimer: null,
    drawTimer: null,
    seedTimer: null,
  };

  const group = $(this).attr('data-content');
  const pathArr = window.location.href.split('/');
  const url = `${pathArr[0]}//${pathArr[2]}`;
  const svgId = `group-${group}`;
  const tooltip = d3.select(`#tooltip_${group}`);
  const self = this;
  let switchInOnTop = true;
  let svg = null;
  let svgDom = null;
  let fullWidth = null;
  let width = null;
  let fullHeight = null;
  let height = null;
  const inColor = '#5FA2DD';
  const outColor = '#F76C51';
  const borderWidth = '3px';
  const inData = [];
  const outData = [];
  let circle = null;
  let outCircle = null;
  let simulation = null;
  let path = null;
  let arc = null;

  function getJson(response) {
    if (!response.ok) return Promise.reject(`${response.status}: ${response.statusText}`);
    return response.json();
  }

  function fillPoints(pointsArr) {
    _.forEach(pointsArr, (point) => {
      const pointObj = {
        id: point.id,
        value: 0,
        r: 0,
        name: point.attributes.name,
        x: 0,
        y: 0,
        seeded: false,
        updating: false,
      };
      if (point.attributes.direction === 'in') {
        inData.push(Object.assign({}, pointObj, { color: inColor, outPoint: false }));
      } else {
        outData.push(Object.assign({}, pointObj, { color: outColor, outPoint: true, startAngle: 0, endAngle: 0 }));
      }
    });
  }

  function dataId(d) {
    return d.id;
  }

  function totalWeight(dataArr) {
    return _.reduce(dataArr, (sum, d) => sum + d.value, 0);
  }

  function dataWeight() {
    const weightIn = totalWeight(inData);
    // return weightIn;
    const weightOut = totalWeight(outData);
    return weightOut > weightIn ? weightOut : weightIn;
  }

  function radius(weight) {
    const zoom = width / 3;
    return d3.scalePow()
      .exponent(0.5)
      .domain([0, weight()])
      .range([2, zoom]);
  }

  function outCombined() {
    return [{
      id: 'outBubble',
      value: _.reduce(outData, (s, d) => s + d.value, 0),
      name: 'Power produced',
      outPoint: true,
    }];
  }

  function recalculateAngles() {
    const totalPower = _.reduce(outData, (s, d) => s + d.value, 0);
    let startAngle = 0;
    _.forEach(outData, (data, idx) => {
      if (data.value === 0) return;
      let endAngle = (data.value / totalPower * 2 * Math.PI + startAngle) || 0;
      if (outData.length > 1 && endAngle > 0.015) endAngle -= 0.015;
      outData[idx].startAngle = startAngle;
      outData[idx].endAngle = endAngle;
      startAngle = endAngle + 0.015;
    });
  }

  function getData() {
    _.forEach(inData, (point, idx) => {
      if (inData[idx].updating) return;
      inData[idx].updating = true;
      fetch(`${url}/api/v1/aggregates/present?register_ids=${point.id}`, {
          headers,
          credentials: 'include',
        })
        .then(getJson)
        .then(json => {
          inData[idx].value = Math.floor(Math.abs(json.power_milliwatt)) || 0;
          inData[idx].seeded = true;
          inData[idx].updating = false;
        })
        .catch(error => {
          inData[idx].value = 0;
          inData[idx].seeded = true;
          inData[idx].updating = false;
          console.log(error);
        });
    });
    _.forEach(outData, (point, idx) => {
      if (outData[idx].updating) return;
      outData[idx].updating = true;
      fetch(`${url}/api/v1/aggregates/present?register_ids=${point.id}`, {
          headers,
          credentials: 'include',
        })
        .then(getJson)
        .then(json => {
          outData[idx].value = Math.floor(Math.abs(json.power_milliwatt)) || 0;
          recalculateAngles();
          outData[idx].seeded = true;
          outData[idx].updating = false;
        })
        .catch(error => {
          outData[idx].value = 0;
          outData[idx].seeded = true;
          outData[idx].updating = false;
          console.log(error);
        });
    });
  }

  function ticked() {
    circle.attr('cx', d => d.x)
      .attr('cy', d => d.y);
  }

  function formatPower(power) {
    const powerArr = power.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,').split(',');
    powerArr.pop();
    return powerArr.join('.');
  }

  function showDetails(data, i, element) {
    if (data.outPoint && data.id !== 'outBubble') {
      d3.select(element).style('opacity', 0.9);
    } else {
      const color = data.outPoint ? outColor : inColor;
      const opacity = data.outPoint ? 0.9 : 0.7;
      d3.select(element).style('stroke', d3.rgb(color).darker().darker());
      d3.select(element).style('opacity', opacity);
    }
    tooltip.transition()
      .duration(500)
      .style('opacity', 1)
      .style('display', 'block');
    tooltip.html(`<b>Name: </b>${data.name}<br /><b>Power: </b>${formatPower(data.value)} Watt`)
      .style('left', `${d3.event.layerX + 20}px`)
      .style('top', `${d3.event.layerY - 20}px`);
  }

  function hideDetails(data, i, element) {
    if (data.outPoint && data.id !== 'outBubble') {
      d3.select(element).style('opacity', 1);
    } else {
      const color = data.outPoint ? outColor : inColor;
      const opacity = data.outPoint ? 1 : 0.9;
      d3.select(element).style('stroke', d3.rgb(color).darker());
      d3.select(element).style('opacity', opacity);
    }
    tooltip.transition()
      .duration(500)
      .style('opacity', 0)
      .style('display', 'none');
  }

  function scaleCenterForce(val) {
    const sortedData = _.sortBy(inData, d => d.value);
    return d3.scaleLinear()
      .domain([_.first(sortedData).value, _.last(sortedData).value])
      .range([0.004, 0.0005]).clamp(true)(val);
  }

  function setHtmlTickers() {
    const powerIn = _.reduce(inData, (s, d) => s + d.value, 0);
    const powerOut = _.reduce(outData, (s, d) => s + d.value, 0);
    $('#kw-ticker-in').html(`${formatPower(powerIn)} W`);
    $('#kw-ticker-out').html(`${formatPower(powerOut)} W`);
    $(`#group-ticker-live-in-${group}`).find('.power-ticker').html(formatPower(powerIn));
    $(`#group-ticker-live-out-${group}`).find('.power-ticker').html(formatPower(powerOut));
  }

  function setSize() {
    svgDom = document.querySelector(`#group-${group}`);
    if (!svgDom) return;
    fullWidth = svgDom.getBoundingClientRect().width;
    width = fullWidth;
    fullHeight = svgDom.getBoundingClientRect().height;
    height = fullHeight;
    if (width > height + height * 0.2) {
      width = height;
    } else if (height > width + width * 0.2) {
      height = width;
    }
  }

  function drawData() {
    $('.waiting-spinner').hide()
    $('.bubbles_container').css('height', $('.bubbles_container').height());
    $('#dummy').remove();

    setHtmlTickers();

    d3.select(`#bubbles_container_${group}`)
      .append('svg')
      .attr('id', svgId)
      .attr('width', '100%')
      .attr('height', '100%');

    svg = d3.select(`#group-${group}`);
    setSize();

    outCircle = svg.selectAll('circle')
      .data(outCombined(), dataId)
      .enter()
      .append('circle')
      .style('fill', outColor)
      .style('stroke', d3.rgb(outColor).darker())
      .style('stroke-width', borderWidth)
      .attr('r', d => radius(dataWeight)(d.value))
      .attr('cx', () => fullWidth / 2)
      .attr('cy', () => fullHeight / 2)
      .on('mouseover', function mouseShow(d, i) { showDetails(d, i, this); })
      .on('mouseout', function mouseHide(d, i) { hideDetails(d, i, this); })
      .on('touchstart', function touchShow(d, i) { showDetails(d, i, this); })
      .on('touchend', function touchHide(d, i) {
        const elementSelf = this;
        setTimeout(() => hideDetails(d, i, elementSelf), 1000);
      });

    _.forEach(inData, (node) => {
      node.x = d3.scaleLinear()
        .domain([0, fullWidth])
        .range([fullWidth * 0.4, fullWidth * 0.6])(Math.random() * fullWidth);
      node.y = d3.scaleLinear()
        .domain([0, fullHeight])
        .range([fullHeight * 0.4, fullHeight * 0.6])(Math.random() * fullHeight);
    });

    arc = d3.arc()
      .startAngle(d => d.startAngle)
      .endAngle(d => d.endAngle)
      .cornerRadius(16)
      .innerRadius(() => radius(dataWeight)(outCombined()[0].value))
      .outerRadius(() => radius(dataWeight)(outCombined()[0].value * 1.1));

    path = svg.selectAll('path')
      .data(outData)
      .enter()
      .append('path')
      .attr('d', arc)
      .attr('id', d => `path_${d.id}`)
      .attr('stroke-width', 4)
      .style('stroke', 'none')
      .attr('transform', `translate(${fullWidth / 2}, ${fullHeight / 2})`)
      .style('fill', d3.rgb(outColor).darker())
      .attr('id', d => d.id)
      .on('click', d => window.location.href = `${url}/registers/${d.id}`)
      .on('mouseover', function mouseShow(d, i) { showDetails(d, i, this); })
      .on('mouseout', function mouseHide(d, i) { hideDetails(d, i, this); })
      .on('touchstart', function touchShow(d, i) { showDetails(d, i, this); })
      .on('touchend', function touchHide(d, i) {
        const elementSelf = this;
        setTimeout(() => hideDetails(d, i, elementSelf), 1000);
      });

    simulation = d3.forceSimulation(inData)
      .velocityDecay(0.2)
      // .alphaDecay(0)
      .force('x', d3.forceX(fullWidth / 2).strength(d => scaleCenterForce(d.value)))
      .force('y', d3.forceY(fullHeight / 2).strength(d => scaleCenterForce(d.value)))
      .force('collide', d3.forceCollide()
        .radius(d => radius(dataWeight)(d.value) + 0.5)
        .strength(0.02)
        .iterations(2))
      .force('charge', d3.forceManyBody()
        .strength(d => d.value * 0.000002 / d3.scaleLinear()
          .domain([0, 300])
          .range([1, 100])(inData.length)))
      .on('tick', ticked);

    const nodes = simulation.nodes();

    circle = svg.selectAll('circle')
      .data(nodes, dataId)
    // .data(data, dataId)
      .enter()
      .append('circle')
      .style('fill', inColor)
      .style('stroke', d3.rgb(inColor).darker())
      .style('stroke-width', borderWidth)
      .style('opacity', 0.9)
      .attr('r', d => radius(dataWeight)(d.value))
      .attr('id', d => d.id)
      .on('click', d => window.location.href = `${url}/registers/${d.id}`)
      .on('mouseover', function mouseShow(d, i) { showDetails(d, i, this); })
      .on('mouseout', function mouseHide(d, i) { hideDetails(d, i, this); })
      .on('touchstart', function touchShow(d, i) { showDetails(d, i, this); })
      .on('touchend', function touchHide(d, i) {
        const elementSelf = this;
        setTimeout(() => hideDetails(d, i, elementSelf), 1000);
      });
  }

  function redrawData() {
    setHtmlTickers();

    circle.transition()
      .ease(d3.easeExpOut)
      .duration(1000)
      .attr('r', d => radius(dataWeight)(d.value));

    // Need to reset params after onResize
    simulation.alpha(0.8)
      .force('x', d3.forceX(fullWidth / 2).strength(d => scaleCenterForce(d.value)))
      .force('y', d3.forceY(fullHeight / 2).strength(d => scaleCenterForce(d.value)))
      .force('charge', d3.forceManyBody()
        .strength(d => d.value * 0.000002 / d3.scaleLinear()
          .domain([0, 300])
          .range([1, 100])(inData.length)))
      .nodes(inData)
      .restart();

    outCircle.data(outCombined(), dataId)
      .transition()
      .ease(d3.easeExpOut)
      .duration(1000)
      .attr('r', d => radius(dataWeight)(d.value));

    arc = d3.arc()
      .startAngle(d => d.startAngle)
      .endAngle(d => d.endAngle)
      .cornerRadius(16)
      .innerRadius(() => radius(dataWeight)(outCombined()[0].value))
      .outerRadius(() => radius(dataWeight)(outCombined()[0].value * 1.1));

    path.transition()
      .ease(d3.easeExpOut)
      .duration(1000)
      .attr('d', arc);
  }

  function onResize() {
    if (!outCircle || !arc || !path || !circle || !simulation) return;

    setSize();

    outCircle.attr('cx', () => fullWidth / 2)
      .attr('cy', () => fullHeight / 2)
      .transition()
      .ease(d3.easeExpOut)
      .duration(1000)
      .attr('r', d => radius(dataWeight)(d.value));

    arc.innerRadius(() => radius(dataWeight)(outCombined()[0].value))
      .outerRadius(() => radius(dataWeight)(outCombined()[0].value * 1.1));

    path.attr('transform', `translate(${fullWidth / 2}, ${fullHeight / 2})`)
      .transition()
      .ease(d3.easeExpOut)
      .duration(1000)
      .attr('d', arc);

    circle.transition()
      .ease(d3.easeExpOut)
      .duration(1000)
      .attr('r', d => radius(dataWeight)(d.value));

    // Params are different from draw/redraw
    simulation.force('x', d3.forceX(fullWidth / 2).strength(d => scaleCenterForce(d.value * 10)))
      .force('y', d3.forceY(fullHeight / 2).strength(d => scaleCenterForce(d.value * 10)))
      .force('charge', d3.forceManyBody()
        .strength(d => d.value * 0.00002 / d3.scaleLinear()
          .domain([0, 300])
          .range([1, 100])(inData.length)))
      .alpha(1)
      .restart();
  }

  function getRegisters() {
    fetch(`${url}/api/v1/groups/${group}/registers`, {
        headers,
        credentials: 'include',
      })
      .then(getJson)
      .then(json => {
        if (json.data.length === 0) return Promise.reject('Empty group');
        fillPoints(json.data);
        getData();
        bubblesTimers.fetchTimer = setInterval(getData, 15000);
        bubblesTimers.seedTimer = setInterval(() => {
          if (!_.find(inData, d => !d.seeded) && !_.find(outData, d => !d.seeded)) {
            clearInterval(bubblesTimers.seedTimer);
            drawData();
            bubblesTimers.drawTimer = setInterval(redrawData, 15000);
          }
        }, 2000);
      })
      .catch(error => {
        console.log(error);
      });
  }

  getRegisters();

  $('.change-order').on('click', () => {
    if (switchInOnTop) {
      switchInOnTop = false;
      circle.lower();
    } else {
      switchInOnTop = true;
      circle.raise();
    }
  });

  $(document).on('page:before-change', () => {
    _.forEach(bubblesTimers, timer => clearInterval(timer));
  });
  $(document).on('page:before-change', $('.bubbles_container').stop());
  $(window).on('resize:end', onResize);
});
