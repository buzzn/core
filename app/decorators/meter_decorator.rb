class MeterDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def edit
    link_to(
      '',
      edit_meter_path(model),
      {
        remote: true,
        class: 'start_modal fa fa-tachometer fa-lg',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end

end