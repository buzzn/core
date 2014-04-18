class DiviceDecorator < Draper::Decorator
  delegate_all

  def gmap_location_header_image_tag
    h.image_tag static_gmap_url([700,100]), class: 'staticMap'
  end

end
