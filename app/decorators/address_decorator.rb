class AddressDecorator < Draper::Decorator
  delegate_all

  def gmap_location_header_image_tag
    h.image_tag static_gmap_url([700,100]), class: 'staticMap'
  end


  def static_gmap_url(size, maptype = 'roadmap')
    return "https://maps.googleapis.com/maps/api/staticmap?center=#{model.latitude},#{model.longitude}&markers=color:red%7Clabel:G%7C#{model.latitude},#{model.longitude}&zoom=14&size=#{size.first}x#{size.last}&maptype=#{maptype}&sensor=false"
  end

end
