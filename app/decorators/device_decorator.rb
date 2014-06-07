class DeviceDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all


  def edit

    if model.up?
      path = edit_up_device_path(model)
    else
      path = edit_down_device_path(model)
    end

    link_to(
      model.name,
      path,
      {
        :remote       => true,
        :class        => 'start_modal',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end

end
