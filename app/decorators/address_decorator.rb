class AddressDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def image_tag_medium
    image_tag static_gmap_url([150,150]), class: 'img-circle', alt: ""
  end

  def image_tag_small
    image_tag static_gmap_url([100,100]), size: '45x45', class: 'img-circle', alt: ""
  end

  def static_gmap_url(size, maptype = 'roadmap')
    return "https://maps.googleapis.com/maps/api/staticmap?center=#{model.latitude},#{model.longitude}&zoom=14&size=#{size.first}x#{size.last}&maptype=#{maptype}&sensor=false"
  end

end
