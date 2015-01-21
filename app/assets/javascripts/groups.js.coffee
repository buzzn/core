timers = []

clearTimers = ->
  i = 0
  while i < timers.length
    window.clearInterval timers[i]
    i++
  timers = []

$(".groups.show").ready ->

  $("#mytab a").click (e) ->
    e.preventDefault()
    $(this).tab "show"

  # Javascript to enable link to tab
  hash = document.location.hash
  $(".nav-pills a[href=" + hash + "]").tab "show"  if hash

  # Change hash for page-reload
  $(".nav-pills a").on "shown.bs.tab", (e) ->
    window.location.hash = e.target.hash
    return

  #for register_id in gon.register_ids
  #
  #  channel = pusher.subscribe("register_#{register_id}")
  #  console.log "subscribed to channel register_#{register_id}"
  #
  #  channel.bind "new_reading", (reading) ->
  #    $("#ticker_#{reading.register_id}").html reading.watt_hour

  #minuteTimer = ->
  #  $("#metering_points").children().each(->
  #    metering_point_id = $(this).attr('id').split('_')[2]
  #    $.getJSON "/metering_points/" + metering_point_id + "/chart?resolution=day_to_hours", (data) ->
  #      $("#metering_point_#{metering_point_id}").find("[id^=chart-]").highcharts().series[0].setData(data[0].data)
  #      console.log "chart-#{metering_point_id} updated"
  #  )

  #timers.push(
  #  window.setInterval(->
  #    minuteTimer()
  #    return
  #  , 1000*60)
  #  )



$(document).on('page:before-change', clearTimers)





jQuery ->
  # Create a comment
  $(".comment-form")
    .on "ajax:beforeSend", (evt, xhr, settings) ->
      $(this).find('textarea')
        .addClass('uneditable-input')
        .attr('disabled', 'disabled');
    .on "ajax:success", (evt, data, status, xhr) ->
      $(this).find('textarea')
        .removeClass('uneditable-input')
        .removeAttr('disabled', 'disabled')
        .val('');
    .on "ajax:error", (evt, data, status, xhr) ->
      $(this).find('textarea')
        .removeClass('uneditable-input')
        .removeAttr('disabled', 'disabled');

  # Delete a comment
  $(document)
    .on "ajax:beforeSend", ".comment", ->
      $(this).fadeTo('fast', 0.5)
    .on "ajax:success", ".comment", ->
      $(this).hide('fast')
    .on "ajax:error", ".comment", ->
      $(this).fadeTo('fast', 1)


class BubbleChart
  constructor: (data, data_out) ->
    @data = data
    @data_out = data_out
    @width = 600
    @height = 600

    @tooltip = CustomTooltip("gates_tooltip", 240)

    # locations the nodes will move towards
    # depending on which view is currently being
    # used
    @center = {x: @width / 2, y: @height / 2}
    @year_centers = {
      "2008": {x: @width / 3, y: @height / 2},
      "2009": {x: @width / 2, y: @height / 2},
      "2010": {x: 2 * @width / 3, y: @height / 2}
    }

    # used when setting up force and
    # moving around nodes
    @layout_gravity = -0.001
    @damper = 0.1

    # these will be set in create_nodes and create_vis
    @vis = null
    @nodes = []
    @nodes_out = []
    @force = null
    @circles = null

    # nice looking colors - no reason to buck the trend
    @fill_color = d3.scale.ordinal()
      .domain(["low", "medium", "high"])
      .range(["#6699FF", "#6699FF", "#6699FF"])

    # use the max watt_hour in the data as the max in the scale's domain
    max_amount = d3.max(@data, (d) -> parseInt(calculate_power(d[3], d[1], d[4], d[2])))
    @radius_scale = d3.scale.pow().exponent(0.5).domain([0, max_amount]).range([2, 85])

    this.create_nodes()
    this.create_vis()



  # create node objects from original data
  # that will serve as the data behind each
  # bubble in the vis, then add each node
  # to @nodes to be used later
  create_nodes: () =>
    @data.forEach (d) =>
      node = {
        id: d[0]
        firstTimestamp: d[3]
        secondTimestamp: d[1]
        firstWattHour: d[4]
        secondWattHour: d[2]
        value: calculate_power(d[3], d[1], d[4], d[2])
        radius: @radius_scale(parseInt(calculate_power(d[3], d[1], d[4], d[2])))
        name: d[5]
        x: Math.random() * 900
        y: Math.random() * 800
        color: "#6699FF"
      }
      @nodes.push node

    @nodes.sort (a,b) -> b.value - a.value



  # create svg at #vis and then
  # create circle representation for each node
  create_vis: () =>
    @vis = d3.select("#vis").append("svg")
      .attr("width", @width)
      .attr("height", @height)
      .attr("id", "svg_vis")

    @circles = @vis.selectAll("circle")
      .data(@nodes, (d) -> d.id)

    # used because we need 'this' in the
    # mouse callbacks
    that = this

    @data_out.forEach (d) =>
      node = {
        id: d[0]
        firstTimestamp: d[3]
        secondTimestamp: d[1]
        firstWattHour: d[4]
        secondWattHour: d[2]
        value: calculate_power(d[3], d[1], d[4], d[2])
        radius: @radius_scale(parseInt(calculate_power(d[3], d[1], d[4], d[2])))
        name: d[5]
        x: @width / 2
        y: @height / 2
        color: "#ff9999"
      }
      @nodes_out.push node
    @nodes.sort (a,b) -> b.value - a.value

    svgContainer = d3.select("#svg_vis")

    @circles_out = svgContainer.selectAll("rect")
      .data(@nodes_out, (d) -> d.id)
      .enter()
      .append("circle")

    circleAttributes = @circles_out
      .attr("cx", (d) -> d.x)
      .attr("cy", (d) -> d.y)
      .attr("r", (d) -> d.radius)
      .style("fill", (d) -> d.color)
      .attr("stroke-width", 10)
      .attr("stroke", (d) => d3.rgb(d.color).darker())
      .on("mouseover", (d,i) -> that.show_details(d,i,this))
      .on("mouseout", (d,i) -> that.hide_details(d,i,this))

    # radius will be set to 0 initially.
    # see transition below
    @circles.enter().append("circle")
      .attr("r", 0)
      .attr("fill", (d) => d.color)
      .attr("stroke-width", 4)
      .attr("stroke", (d) => d3.rgb(d.color).darker())
      .attr("id", (d) -> "bubble_#{d.id}")
      .on("mouseover", (d,i) -> that.show_details(d,i,this))
      .on("mouseout", (d,i) -> that.hide_details(d,i,this))
      .style("opacity", 0.9)

    # Fancy transition to make bubbles appear, ending with the
    # correct radius
    @circles.transition().duration(2000).attr("r", (d) -> d.radius)




  # Charge function that is called for each node.
  # Charge is proportional to the diameter of the
  # circle (which is stored in the radius attribute
  # of the circle's associated data.
  # This is done to allow for accurate collision
  # detection with nodes of different sizes.
  # Charge is negative because we want nodes to
  # repel.
  # Dividing by 8 scales down the charge to be
  # appropriate for the visualization dimensions.
  charge: (d) ->
    -Math.pow(d.radius, 2.0) / 7

  # Starts up the force layout with
  # the default values
  start: () =>
    @force = d3.layout.force()
      .nodes(@nodes)
      .size([@width, @height])

  # Sets up force layout to display
  # all nodes in one circle.
  display_group_all: () =>
    @force.gravity(@layout_gravity)
      .charge(this.charge)
      .friction(0.9)
      .on "tick", (e) =>
        @circles.each(this.move_towards_center(e.alpha))
          .attr("cx", (d) -> d.x)
          .attr("cy", (d) -> d.y)
    @force.start()

    this.hide_years()

  # Moves all circles towards the @center
  # of the visualization
  move_towards_center: (alpha) =>
    (d) =>
      d.x = d.x + (@center.x - d.x) * (@damper + 0.02) * alpha
      d.y = d.y + (@center.y - d.y) * (@damper + 0.02) * alpha

  # sets the display of bubbles to be separated
  # into each year. Does this by calling move_towards_year
  #display_by_year: () =>
  #  @force.gravity(@layout_gravity)
  #    .charge(this.charge)
  #    .friction(0.9)
  #    .on "tick", (e) =>
  #      @circles.each(this.move_towards_year(e.alpha))
  #        .attr("cx", (d) -> d.x)
  #        .attr("cy", (d) -> d.y)
  #  @force.start()
  #
  #  this.display_years()

  # move all circles to their associated @year_centers
  #move_towards_year: (alpha) =>
  #  (d) =>
  #    target = @year_centers[d.year]
  #    d.x = d.x + (target.x - d.x) * (@damper + 0.02) * alpha * 1.1
  #    d.y = d.y + (target.y - d.y) * (@damper + 0.02) * alpha * 1.1

  # Method to display year titles
  #display_years: () =>
  #  years_x = {"2008": 160, "2009": @width / 2, "2010": @width - 160}
  #  years_data = d3.keys(years_x)
  #  years = @vis.selectAll(".years")
  #    .data(years_data)

  #  years.enter().append("text")
  #    .attr("class", "years")
  #    .attr("x", (d) => years_x[d] )
  #    .attr("y", 40)
  #    .attr("text-anchor", "middle")
  #    .text((d) -> d)

  # Method to hide year titiles
  hide_years: () =>
    years = @vis.selectAll(".years").remove()

  show_details: (data, i, element) =>
    d3.select(element).attr("stroke", (d) -> d3.rgb(d.color).darker().darker())
    content = "<span class=\"name\">Name:</span><span class=\"value\"> #{data.name}</span><br/>"
    content +="<span class=\"name\">Aktueller Bezug:</span><span class=\"value\"> #{addCommas(parseInt(data.value)).replace(",", ".")} Watt</span><br/>"
    @tooltip.showTooltip(content,d3.event)


  hide_details: (data, i, element) =>
    d3.select(element).attr("stroke", (d) => d3.rgb(d.color).darker())
    @tooltip.hideTooltip()

  reset_radius: (id, value, timestamp) =>
    @nodes.forEach (d) =>
      if d.id.toString() == id.toString()
        d.firstTimestamp = d.secondTimestamp
        d.firstWattHour = d. secondWattHour
        d.secondTimestamp = timestamp
        d.secondWattHour = value
        d.value = calculate_power(d.firstTimestamp, d.secondTimestamp, d.firstWattHour, d.secondWattHour)
        d.radius = @radius_scale(parseInt(calculate_power(d.firstTimestamp, d.secondTimestamp, d.firstWattHour, d.secondWattHour)))

    @nodes_out.forEach (d) =>
      if d.id.toString() == id.toString()
        d.firstTimestamp = d.secondTimestamp
        d.firstWattHour = d. secondWattHour
        d.secondTimestamp = timestamp
        d.secondWattHour = value
        d.value = calculate_power(d.firstTimestamp, d.secondTimestamp, d.firstWattHour, d.secondWattHour)
        d.radius = @radius_scale(parseInt(calculate_power(d.firstTimestamp, d.secondTimestamp, d.firstWattHour, d.secondWattHour)))

    #@circles = @vis.selectAll("circle")
    #  .data(@nodes, (d) -> d.id)
    @circles.transition().duration(2000).attr("r", (d) -> d.radius)
    @circles_out.transition().duration(2000).attr("r", (d) -> d.radius)
    #@circles.attr("r", (d) -> d.radius)

    this.display_group_all()

  calculate_power = (firstTimestamp, secondTimestamp, firstWattHour, secondWattHour) =>
    return (secondWattHour - firstWattHour)*3600/((secondTimestamp - firstTimestamp)*10000)




root = exports ? this

$ ->
  chart = null

  render_vis = (data, data_out) ->
    chart = new BubbleChart data, data_out
    chart.start()
    root.display_all()
  root.display_all = () =>
    chart.display_group_all()
  root.display_year = () =>
    chart.display_by_year()
  root.toggle_view = (view_type) =>
    if view_type == 'year'
      root.display_year()
    else
      root.display_all()

  data_in = gon.in_metering_point_data
  data_out = gon.out_metering_point_data

  render_vis data_in, data_out







  Pusher.host    = gon.pusher_host
  Pusher.ws_port = 8080
  Pusher.wss_port = 8080
  pusher = new Pusher(gon.pusher_key)

  for register_id in gon.register_ids

    channel = pusher.subscribe("register_#{register_id}")
    channel.bind "new_reading", (reading) ->
      chart.reset_radius(reading.register_id, reading.watt_hour, reading.timestamp)


  #window.setInterval(->
  #  chart.reset_radius()
  #, 1000*5)

addCommas = (nStr) ->
  nStr += ""
  x = nStr.split(".")
  x1 = x[0]
  x2 = (if x.length > 1 then "." + x[1] else "")
  rgx = /(\d+)(\d{3})/
  x1 = x1.replace(rgx, "$1" + "," + "$2")  while rgx.test(x1)
  x1 + x2

csvArr = (csv) ->
  lines = csv.toString().split("\n,")
  lines.splice(0, 1)
  entry = []
  result = []
  lines.forEach (l) =>
    entry = []
    values = l.split(",")
    values.forEach (v) =>
      entry.push(v)
    result.push(entry)
  return result





