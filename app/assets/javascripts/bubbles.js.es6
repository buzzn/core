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
  const self = this;
  const token = gon.global.access_token;

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
        inData.push(Object.assign({}, pointObj, { color: inColor }));
      } else {
        outData.push(Object.assign({}, pointObj, { color: outColor }));
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
    return [{ id: 'outBubble', value: _.reduce(outData, (s, d) => s + d.value, 0) }];
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

  function showDetails(data, i, element) {
    d3.select(element).style('stroke', d3.rgb(inColor).darker().darker());
    d3.select(element).style('opacity', 0.6);
  }

  function hideDetails(data, i, element) {
    d3.select(element).style('stroke', d3.rgb(inColor).darker());
    d3.select(element).style('opacity', 0.8);
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
        .range([width / 100 * 20, width / 100 * 80])(Math.random() * width);
      node.y = d3.scaleLinear()
        .domain([0, width])
        .range([width / 100 * 20, width / 100 * 80])(Math.random() * height);
    });

    simulation = d3.forceSimulation(inData)
      .velocityDecay(0.2)
      // .alphaDecay(0)
      .force('x', d3.forceX().strength(0.002))
      .force('y', d3.forceY().strength(0.002))
      .force('collide', d3.forceCollide()
        .radius(d => radius(dataWeight)(d.value) + 0.5)
        .strength(0.02)
        .iterations(2))
      .force('charge', d3.forceManyBody()
        .strength(5))
      .force('center', d3.forceCenter(fullWidth / 2, fullHeight / 2))
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
      // .force('x', null)
      // .force('y', null)
      .force('x', d3.forceX().strength(0.001))
      .force('y', d3.forceY().strength(0.001))
      .force('charge', d3.forceManyBody()
        .strength(0.5))
      .nodes(inData)
      .restart();

    outCircle.data(outCombined(), dataId)
      .transition()
      .duration(500)
      .attr('r', d => radius(dataWeight)(d.value));
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

  $(document).on('page:before-change', () => {
    _.forEach(bubblesTimers, timer => clearInterval(timer));
  })
  $(document).on('page:before-change', $('.bubbles_container').stop())
});
