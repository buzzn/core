class MeterDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def edit
    h.link_to(
      t('edit_meter'),
      edit_meter_path(model),
      {
        remote: true,
        class: 'start_modal',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end

end