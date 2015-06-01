$("#map").ready ->
  handler = Gmaps.build('Google')
  handler.buildMap {
    provider: {}
    internal: id: 'map'
  }, ->
    $.ajax({url: '/addresses.json', dataType: 'json'})
      .success (data) ->
        console.log data
        markers = handler.addMarkers(data)
        handler.bounds.extendWith markers
        handler.fitMapToBounds()
    return