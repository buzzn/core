$(".address").ready ->
  handler = Gmaps.build('Google')
  handler.buildMap {
    provider: {}
    internal: id: 'map'
  }, ->
    m = handler.addMarkers(gon.markers)
    handler.bounds.extendWith m
    handler.fitMapToBounds()

