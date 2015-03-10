class AddressDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all



  def static_gmap_url(size, maptype = 'roadmap')
    return "https://maps.googleapis.com/maps/api/staticmap?center=#{model.latitude},#{model.longitude}&zoom=14&size=#{size}&maptype=#{maptype}&sensor=false"
  end




  def link_to_edit
    link_to(
      t('edit'),
      edit_address_path(model),
      {
        :remote       => true,
        :class        => 'start_modal btn btn-primary btn-rounded btn-labeled fa fa-cog',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end


  def link_to_delete
    link_to(
      t('delete'),
      model,
      remote: false,
      class: 'btn btn-danger',
      :method => :delete,
      :data => {
        :confirm => t('are_you_sure')
    })
  end


end
