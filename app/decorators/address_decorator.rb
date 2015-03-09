class AddressDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all



  def static_gmap_url(size, maptype = 'roadmap')
    return "https://maps.googleapis.com/maps/api/staticmap?center=#{model.latitude},#{model.longitude}&zoom=14&size=#{size}&maptype=#{maptype}&sensor=false"
  end

end
