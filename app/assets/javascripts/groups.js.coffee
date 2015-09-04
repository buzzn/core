


class BubbleChart
  constructor: (data, data_out, group_id) ->
    @data = data
    @data_out = data_out
    canvasWidth = $("#bubbles_container_" + group_id).width()
    canvasHeight = $("#bubbles_container_" + group_id).height()
    @width = canvasWidth
    @height = canvasHeight
    if @width < @height
      @height = @width

    @tooltip = CustomTooltip("gates_tooltip_" + group_id, 240)

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
    @partition = null
    @nodes = []
    @nodes_out = []
    @path = null
    @arc = null
    @radius_out = null
    @force = null
    @circles = null
    @max_power = null
    @max_power_in = null
    @totalPower = 0
    @totalPowerOut = 0
    @radius_scale = null
    @zoomFactor = 1

    # nice looking colors - no reason to buck the trend
    @fill_color = d3.scale.ordinal()
      .domain(["low", "medium", "high"])
      .range(["#5FA2DD", "#5FA2DD", "#5FA2DD"])

    # use the max watt_hour in the data as the max in the scale's domain
    @max_power_in = d3.max(@data, (d) -> parseInt(d.latest_power))
    max_power_out = 0 #max_power_out is equal to totalPowerOut !!
    @data_out.children.forEach (d) ->
      max_power_out += d.latest_power
    @totalPowerOut = max_power_out
    if @max_power_in > max_power_out
      @max_power = @max_power_in
    else
      @max_power = max_power_out
    @data.forEach (d) =>
      @totalPower += parseInt(d.latest_power)
    this.setZoomFactor()
    this.create_nodes()
    this.create_vis(group_id)
    this.calculateTotalPower()
    this.calculateTotalPowerOut()



  # create node objects from original data
  # that will serve as the data behind each
  # bubble in the vis, then add each node
  # to @nodes to be used later
  create_nodes: () =>
    @data.forEach (d) =>
      color = "#5FA2DD"
      if d.own_metering_point
        color = d3.rgb('#5FA2DD').darker()
        #color = "#6A5ACD"
      node = {
        id: d.metering_point_id
        value: d.latest_power
        radius: @radius_scale(parseInt(d.latest_power))
        name: d.name
        x: Math.random() * @width
        y: Math.random() * @height
        color: color
      }
      @nodes.push node

    @nodes.sort (a,b) -> b.value - a.value



  # create svg at #vis and then
  # create circle representation for each node
  create_vis: (group_id) =>

    @vis = d3.select("#bubbles_container_" + group_id).append("svg")
      .attr("id", "svg_vis")
      .attr("width", "100%")
      .attr("height", "100%")

    @circles = @vis.selectAll("circle")
      .data(@nodes, (d) -> d.id)

    # used because we need 'this' in the
    # mouse callbacks
    that = this

    svg = d3.select("#bubbles_container_" + group_id).select("#svg_vis")
      .append("g")
      .attr('id', 'circles_out')
      .attr("transform", "translate(" + @width / 2 + "," + @height / 2 + ")")

    #radius = Math.min(@width, @height) / 2
    radius_out = @radius_scale(parseInt(@totalPowerOut))
    @radius_out = radius_out

    partition = d3.layout.partition()
      .sort(null)
      .size([2 * Math.PI, radius_out * radius_out])
      .value((d) ->  d.latest_power)

    @partition = partition

    arc = d3.svg.arc()
      .startAngle((d) ->  d.x)
      .endAngle((d) ->  d.x + d.dx)
      .innerRadius((d) ->  if d.children then 0 else radius_out)
      .outerRadius((d) -> if d.children then radius_out else radius_out * 1.1)

    @arc = arc

    @path = svg.selectAll('path')
      .data(partition.nodes(@data_out))
      .enter()
      .append('path')
      .attr('d', arc)
      .attr('id', (d) -> "path_" + d.metering_point_id)
      .attr("stroke-width", (d) -> if d.children then 0 else 4)
      .style('stroke', (d) -> 'none')
      .style('fill', (d) -> if d.children then '#F76C51' else d3.rgb('#F76C51').darker())
      .on("mouseover", (d,i) -> that.show_details(d,i,this))
      .on("mouseout", (d,i) -> that.hide_details(d,i,this))

    # @data_out.forEach (d) =>
    #   node = {
    #     id: d.metering_point_id
    #     value: d.latest_power
    #     radius: @radius_scale(parseInt(d.latest_power)) * 1.1
    #     name: d.name
    #     x: @width / 2
    #     y: @height / 2
    #     color: "#F76C51"
    #   }
    #   @nodes_out.push node
    # @nodes_out.sort (a,b) -> b.value - a.value

    svgContainer = d3.select("#bubbles_container_" + group_id).select("#svg_vis")

    # @circles_out = svgContainer.selectAll("rect")
    #   .data(@nodes_out, (d) -> d.id)
    #   .enter()
    #   .append("circle")

    # circleAttributes = @circles_out
    #   .attr("id", (d) -> "bubble_#{d.id}")
    #   .attr("cx", (d) -> d.x)
    #   .attr("cy", (d) -> d.y)
    #   .attr("r", (d) -> d.radius)
    #   .style("fill", (d) -> d.color)
    #   .attr("stroke-width", 8)
    #   .attr("stroke", (d) => d3.rgb(d.color).darker())
    #   .on("mouseover", (d,i) -> that.show_details(d,i,this))
    #   .on("mouseout", (d,i) -> that.hide_details(d,i,this))

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
    #@circles.transition().duration(2000).attr("r", (d) -> d.radius)
    @circles.attr("r", (d) -> d.radius)




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
      .on "end", (e) =>
      #  @circles.each(this.move_towards_center(e.alpha))
      #    .attr("cx", (d) -> d.x)
      #    .attr("cy", (d) -> d.y)
    @force.start()


  # Moves all circles towards the @center
  # of the visualization
  move_towards_center: (alpha) =>
    (d) =>
      d.x = d.x + (@center.x - d.x) * (@damper + 0.02) * alpha
      d.y = d.y + (@center.y - d.y) * (@damper + 0.02) * alpha

  show_details: (data, i, element) =>
    d3.select(element).attr("stroke", (d) -> d3.rgb(d.color).darker().darker())
    d3.select(element).attr("opacity", 0.7)
    content = "<span class=\"name\">Name:</span><span class=\"value\"> #{data.name}</span><br/>"
    content +="<span class=\"name\">Aktuelle Leistung:</span><span class=\"value\"> #{addCommas(parseInt(data.value)).replace(",", ".")} Watt</span><br/>"
    @tooltip.showTooltip(content,d3.event)


  hide_details: (data, i, element) =>
    d3.select(element).attr("stroke", (d) => d3.rgb(d.color).darker())
    d3.select(element).attr("opacity", 1)
    @tooltip.hideTooltip()

  reset_radius: (id, value) =>

    @nodes.forEach (d) =>
      if d.id.toString() == id.toString()
        if value == d.value
          return
        d.value = value
        this.calculateMaxPower(d.value)
        d.radius = @radius_scale(parseInt(value))

    @data_out.children.forEach (d) =>
      if d.metering_point_id.toString() == id.toString()
        if d.latest_power == value
          return
        d.latest_power = value
        @path = d3.select("circles_out").selectAll('path')
          .data(@partition.nodes(@data_out))
        this.calculateMaxPower(value)
        #resetRadiusArc()

    # @nodes_out.forEach (d) =>
    #   if d.id.toString() == id.toString()
    #     if value == d.value
    #       return
    #     d.value = value
    #     this.calculateMaxPower(d.value)
    #     d.radius = @radius_scale(parseInt(value)) * 1.1


    #@circles = @vis.selectAll("circle")
    #  .data(@nodes, (d) -> d.id)
    #@circles.attr("r", (d) -> d.radius)

    @circles.transition().duration(2000).attr("r", (d) -> d.radius)
    #@circles_out.transition().duration(2000).attr("r", (d) -> d.radius)
    #@circles.attr("r", (d) -> d.radius)
    #@circles_out.attr("r", (d) -> d.radius)
    this.display_group_all()

  calculateNewCenter: () =>
    @height = $(".bubbles_container").height()
    @width = $(".bubbles_container").width()
    @center = {x: @width / 2, y: @height / 2}
    # circleAttributes = @circles_out
    #   .attr("cx", @width / 2)
    #   .attr("cy", @height / 2)
    d3.select("#circles_out")
      .attr("transform", "translate(" + @width / 2 + "," + @height / 2 + ")")
    this.setNewScale()

  calculateMaxPower: (value) =>
    @max_power_in = d3.max(@nodes, (d) -> parseInt(value))
    max_power_out = 0 #max_power_out is equal to totalPowerOut !!
    @data_out.children.forEach (d) ->
      max_power_out += d.latest_power
    if @max_power_in > max_power_out
      @max_power = @max_power_in
      #if value > @max_power_in
      #  @max_power = value
    else
      @max_power = max_power_out
      #if value > max_power_out
      #  @max_power = value
    this.calculateTotalPower()
    this.calculateTotalPowerOut()
    this.setNewScale()

  setNewScale: () =>
    this.setZoomFactor()
    @nodes.forEach (d) =>
      d.radius = @radius_scale(parseInt(d.value))
    this.resetRadiusArc()
    @circles.transition().duration(2000).attr("r", (d) -> d.radius)
    #@circles_out.transition().duration(2000).attr("r", (d) -> d.radius)
    #@circles.attr("r", (d) -> d.radius)
    #@circles_out.attr("r", (d) -> d.radius)
    this.display_group_all()

  calculateTotalPower: () =>
    totalPower = 0
    @nodes.forEach (d) =>
      totalPower += d.value
    @totalPower = totalPower
    $("#kw-ticker-in").html(parseInt(@totalPower) + " W")

  calculateTotalPowerOut: () =>
    totalPowerOut = 0
    @data_out.children.forEach (d) ->
      totalPowerOut += d.latest_power
    @totalPowerOut = totalPowerOut
    $("#kw-ticker-out").html(parseInt(@totalPowerOut) + " W")

  setZoomFactor: () =>
    smallest_border = @height
    if smallest_border == null
      throw ''
    if @width < @height
      smallest_border = @width
    @zoomFactor = smallest_border / 3
    @radius_scale = d3.scale.pow().exponent(0.5).domain([0, @max_power]).range([2, @zoomFactor])
    while @radius_scale(@totalPower) > smallest_border / 2.4
      @zoomFactor = @zoomFactor - 20
      @radius_scale = d3.scale.pow().exponent(0.5).domain([0, @max_power]).range([2, @zoomFactor])

  resetRadiusArc: () =>
    radius_out = @radius_scale(parseInt(@totalPowerOut))
    @radius_out = radius_out
    @arc = d3.svg.arc()
      .startAngle((d) ->  d.x)
      .endAngle((d) ->  d.x + d.dx)
      .innerRadius((d) ->  if d.children then 0 else radius_out)
      .outerRadius((d) -> if d.children then radius_out else radius_out * 1.1)
    d3.select("#circles_out").selectAll('path').transition()
      .duration(2000)
      .attr('d', @arc)








root = exports ? this
timers = []

$(".bubbles_container").ready ->
  chart = null

  render_vis = (data, data_out, group_id) ->
    chart = new BubbleChart data, data_out, group_id
    chart.start()
    chart.display_group_all()

  group_id = $(this).attr('data-content')
  $.ajax({url: '/groups/' + group_id + '/bubbles_data'})
    .success (data) ->
      data_in = data.in
      data_out = data.out

      interval = 0.33 * data_in.length + 10

      render_vis data_in, data_out, group_id

      data_out.children.forEach (metering_point_data) ->
        actual_out_metering_point_id = metering_point_data.metering_point_id
        if metering_point_data.readable
          $('#path_' + actual_out_metering_point_id).css( 'cursor', 'pointer' )
          $('#path_' + actual_out_metering_point_id).click ->
            window.location.href = '/metering_points/' + $(this).attr('id').split('_')[1]
        timers.push(
          window.setInterval(->
            pullPowerData(chart, actual_out_metering_point_id)
            return
          , 1000*interval)
          )
      data_in.forEach (metering_point_data) ->
        actual_in_metering_point_id = metering_point_data.metering_point_id
        if metering_point_data.readable
          $('#bubble_' + actual_in_metering_point_id).css( 'cursor', 'pointer' )
          $('#bubble_' + actual_in_metering_point_id).click ->
            window.location.href = '/metering_points/' + $(this).attr('id').split('_')[1]
        timers.push(
          window.setInterval(->
            pullPowerData(chart, actual_in_metering_point_id)
            return
          , 1000*interval)
          )

      $(window).on "resize:end", chart.calculateNewCenter


# $(".group_scores").ready ->
#   group_id = $(this).attr('data-content')
#   $.ajax({url: '/groups/' + group_id + '/get_scores'})
#     .success (data) ->
#       sufficiency = Number((data.sufficiency).toFixed(0))
#       $(".score_sufficiency").append("<div class=circle-filled></div>") for [1..sufficiency] if sufficiency
#       $(".score_sufficiency").append("<div class=circle-empty></div>") for [1..(5 - sufficiency)] if (5 - sufficiency)

#       closeness = Number((data.closeness).toFixed(0))
#       $(".score_closeness").append("<div class=circle-filled></div>") for [1..closeness] if closeness
#       $(".score_closeness").append("<div class=circle-empty></div>") for [1..(5 - closeness)] if (5 - closeness)

#       autarchy = Number((data.autarchy).toFixed(0))
#       $(".score_autarchy").append("<div class=circle-filled></div>") for [1..autarchy] if autarchy
#       $(".score_autarchy").append("<div class=circle-empty></div>") for [1..(5 - autarchy)] if (5 - autarchy)

#       fitting = Number((data.fitting).toFixed(0))
#       $(".score_fitting").append("<div class=circle-filled></div>") for [1..fitting] if fitting
#       $(".score_fitting").append("<div class=circle-empty></div>") for [1..(5 - fitting)] if (5 - fitting)
#       $(".circle-filled").addClass("fa fa-circle")
#       $(".circle-empty").addClass("fa fa-circle-o")


$(".comments-panel").ready ->
  group_id = $(".bubbles_container").attr('data-content')
  Pusher.host    = $(".pusher").data('pusherhost')
  Pusher.ws_port = 8080
  Pusher.wss_port = 8080
  pusher = new Pusher($(".pusher").data('pusherkey'))

  channel = pusher.subscribe("Group_#{group_id}")
  console.log 'subscribed to ' + group_id
  channel.bind "new_comment", (comment) ->
    console.log 'incoming comment'
    if pusher.connection.socket_id != comment.socket_id
      html = '' +
        '<li class="mar-btm comment" id="comment_' + comment.id + '">
          <div class="media-left">
            <img alt="' + comment.img_alt + '" class="img-circle img-sm" src="' + comment.image + '"/>
          </div>
          <div class="media-body pad-hor speech-left">
            <div class="speech">
              <a class="media-heading" href="' + comment.profile_href + '">
                ' + comment.user_name + '
              </a>
              <p>
                ' + comment.body + '
              </p>
              <div class="likes pull-right">
                <p class="speech-time">
                  <i class="increase-likes fa fa-thumbs-o-up"></i>
                  <div class="likes-count">
                    <%=' + comment.likes + '%>
                  </div>
                </p>
              </div>
              <p class="speech-time time">
                <i class="fa fa-clock-o fa-fw"></i>
                ' + comment.created_at + '
              </p>
            </div>
          </div>
        </li>'
      $(".comments-all").append(html).hide().show('slow');
      $(".comments-content").animate({
        scrollTop: $("#comment_" + comment.id).offset().top
      }, 1000)
      that = $("#comment_#{coment.id}")
      that.find(".increase-likes").on "click", ->
        $.ajax({url: '/comments/' + comment_id + '/increase_likes', dataType: 'json'})
          .success (data) ->
            that.find(".likes-count").html(data.likes)
            that.find(".increase-likes").unbind "click"
    else
      $("#comment_" + comment.id).waitUntilExists( ->
        $(".comments-content").animate({
          scrollTop: $("#comment_" + comment.id).offset().top
        }, 1000)
      )

  $(this).find(".comment").each ->
    comment_id = $(this).attr('id').split('_')[1]
    that = $(this)
    that.find(".increase-likes").on "click", ->
      $.ajax({url: '/comments/' + comment_id + '/increase_likes', dataType: 'json'})
        .success (data) ->
          that.find(".likes-count").html(data.likes)
          that.find(".increase-likes").unbind "click"

  $(this).on "ajax:beforeSend", (evt, xhr, settings) ->
    settings.data += '&socket_id=' + pusher.connection.socket_id
    $(this).find('textarea')
      .addClass('uneditable-input')
      .attr('disabled', 'disabled');
  $(this).on "ajax:success", (evt, data, status, xhr) ->
    $(this).find('textarea')
      .removeClass('uneditable-input')
      .removeAttr('disabled', 'disabled')
      .val('');
  $(this).on "ajax:error", (evt, data, status, xhr) ->
    $(this).find('textarea')
      .removeClass('uneditable-input')
      .removeAttr('disabled', 'disabled');





addCommas = (nStr) ->
  nStr += ""
  x = nStr.split(".")
  x1 = x[0]
  x2 = (if x.length > 1 then "." + x[1] else "")
  rgx = /(\d+)(\d{3})/
  x1 = x1.replace(rgx, "$1" + "," + "$2")  while rgx.test(x1)
  x1 + x2

pullPowerData = (chart, metering_point_id) ->
  $.ajax({url: '/metering_points/' + metering_point_id + '/latest_power', async: true, dataType: 'json'})
    .success (data) ->
      if data.online || data.virtual
        if data.latest_power != null
          chart.reset_radius(metering_point_id, data.latest_power) #TODO: check timestamp
      #else
        #chart.reset_radius(metering_point_id, 0)
clearTimers = ->
  i = 0
  while i < timers.length
    window.clearInterval timers[i]
    i++
  timers = []


$(document).on('page:before-change', clearTimers)
$(document).on('page:before-change', $(".bubbles_container").stop())
# Delete a comment
$(document)
  .on "ajax:beforeSend", ".comment", ->
    $(this).fadeTo('fast', 0.5)
  .on "ajax:success", ".comment", ->
    $(this).hide('fast')
  .on "ajax:error", ".comment", ->
    $(this).fadeTo('fast', 1)














