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
  const token = gon.global.access_token;

  let switchInOnTop = true;
  let svg = null;
  let svgDom = null;
  let fullWidth = null;
  let width = null;
  let fullHeight = null;
  let height = null;
  const inColor = '#5FA2DD';
  const outColor = '#F76C51';
  const borderWidth = '6px';
  const inData = [];
  const outData = [];
  const headers = {
    Accept: 'application/json',
  };
  if (token && token.length > 0) headers.Authorization = `Bearer ${token}`;
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
      if (point.attributes.mode === 'in') {
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
      const endAngle = data.value / totalPower * 2 * Math.PI + startAngle;
      outData[idx].startAngle = startAngle;
      outData[idx].endAngle = endAngle;
      startAngle = endAngle;
    });
  }

  function calculateArcColor(data) {
    const totalPower = _.reduce(outData, (s, d) => s + d.value, 0);
    const hsl = d3.hsl(outColor).darker();
    hsl.h = d3.scaleLinear()
      .domain([0, totalPower])
      .range([hsl.h - 40, hsl.h + 40])(data.value);
    return d3.hsl(hsl).toString();
  }

  function getData() {
    _.forEach(inData, (point, idx) => {
      if (inData[idx].updating) return;
      inData[idx].updating = true;
      fetch(`${url}/api/v1/aggregates/present?metering_point_ids=${point.id}`, { headers })
        .then(getJson)
        .then(json => {
          inData[idx].value = Math.abs(json.power_milliwatt) || 0;
          inData[idx].seeded = true;
          inData[idx].updating = false;
        })
        .catch(error => {
          inData[idx].updating = false;
          console.log(error);
        });
    });
    _.forEach(outData, (point, idx) => {
      if (outData[idx].updating) return;
      outData[idx].updating = true;
      fetch(`${url}/api/v1/aggregates/present?metering_point_ids=${point.id}`, { headers })
        .then(getJson)
        .then(json => {
          outData[idx].value = Math.abs(json.power_milliwatt) || 0;
          recalculateAngles();
          outData[idx].seeded = true;
          outData[idx].updating = false;
        })
        .catch(error => {
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
    const powerArr = power.toLocaleString('en').split(',');
    powerArr.pop();
    return powerArr.join('.');
  }

  function showDetails(data, i, element) {
    const color = data.outPoint ? outColor : inColor;
    const opacity = data.outPoint ? 0.8 : 0.6;
    d3.select(element).style('stroke', d3.rgb(color).darker().darker());
    d3.select(element).style('opacity', opacity);
    tooltip.transition()
      .duration(500)
      .style('opacity', 1)
      .style('display', 'block');
    tooltip.html(`<b>Name: </b>${data.name}<br /><b>Power: </b>${formatPower(data.value)} Watt`)
      .style('left', `${d3.event.layerX + 20}px`)
      .style('top', `${d3.event.layerY - 20}px`);
  }

  function hideDetails(data, i, element) {
    const color = data.outPoint ? outColor : inColor;
    const opacity = data.outPoint ? 1 : 0.8;
    d3.select(element).style('stroke', d3.rgb(color).darker());
    d3.select(element).style('opacity', opacity);
    tooltip.transition()
      .duration(500)
      .style('opacity', 0)
      .style('display', 'none');
  }

  function scaleCenterForce(val) {
    const sortedData = _.sortBy(inData, d => d.value);
    return d3.scaleLinear()
      .domain([_.first(sortedData).value, _.last(sortedData).value])
      .range([0.001, 0.0015])(val);
  }

  function drawData() {
    $('.waiting-spinner').hide()
    $('.bubbles_container').css('height', $('.bubbles_container').height());
    $('#dummy').remove();
    d3.select(`#bubbles_container_${group}`)
      .append('svg')
      .attr('id', svgId)
      .attr('width', '100%')
      .attr('height', '100%');

    svg = d3.select(`#group-${group}`);
    svgDom = document.querySelector(`#group-${group}`);
    fullWidth = svgDom.getBoundingClientRect().width;
    width = fullWidth;
    fullHeight = svgDom.getBoundingClientRect().height;
    height = fullHeight;
    if (width > height + height / 100 * 20) {
      width = height;
    } else if (height > width + width / 100 * 20) {
      height = width;
    }

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
        .domain([0, width])
        .range([width / 100 * 30, width / 100 * 70])(Math.random() * width);
      node.y = d3.scaleLinear()
        .domain([0, width])
        .range([width / 100 * 30, width / 100 * 70])(Math.random() * height);
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
      .style('fill', d => calculateArcColor(d))
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
        .strength(d => d.value * 0.000002))
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
      .style('opacity', '0.8')
      .attr('r', d => radius(dataWeight)(d.value))
      .on('mouseover', function mouseShow(d, i) { showDetails(d, i, this); })
      .on('mouseout', function mouseHide(d, i) { hideDetails(d, i, this); })
      .on('touchstart', function touchShow(d, i) { showDetails(d, i, this); })
      .on('touchend', function touchHide(d, i) {
        const elementSelf = this;
        setTimeout(() => hideDetails(d, i, elementSelf), 1000);
      });
  }

  function redrawData() {
    circle.transition()
      .duration(50)
      .attr('r', d => radius(dataWeight)(d.value));

    simulation.alpha(0.8)
      .nodes(inData)
      .restart();

    outCircle.data(outCombined(), dataId)
      .transition()
      .duration(1000)
      .attr('r', d => radius(dataWeight)(d.value));

    arc = d3.arc()
      .startAngle(d => d.startAngle)
      .endAngle(d => d.endAngle)
      .cornerRadius(16)
      .innerRadius(() => radius(dataWeight)(outCombined()[0].value))
      .outerRadius(() => radius(dataWeight)(outCombined()[0].value * 1.1));

    path.transition()
      .duration(1000)
      .attr('d', arc);
  }

  fetch(`${url}/api/v1/groups/${group}/metering-points?per_page=10000`, { headers })
    .then(getJson)
    .then(json => {
      if (json.data.length === 0) return Promise.reject('Empty group');
      fillPoints(json.data);
      getData();
      bubblesTimers.fetchTimer = setInterval(getData, 8000);
      bubblesTimers.seedTimer = setInterval(() => {
        if (!_.find(inData, d => !d.seeded) && !_.find(outData, d => !d.seeded)) {
          clearInterval(bubblesTimers.seedTimer);
          drawData();
          bubblesTimers.drawTimer = setInterval(redrawData, 8000);
        }
      }, 2000);
    })
    .catch(error => {
      console.log(error);
    });

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
  })
  $(document).on('page:before-change', $('.bubbles_container').stop())
});
