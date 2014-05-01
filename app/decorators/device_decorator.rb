class DeviceDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all


  def edit
    link_to(
      t('edit_devise'),
      edit_device_path(model),
      {
        :remote       => true,
        :class        => 'start_modal',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end

end
