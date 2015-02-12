class RegisterDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  decorates_association :metering_point

  def panel_mode_class
    case model.mode
    when 'in'
      'primary'
    when 'out'
      'danger'
    end
  end

  def name
    t(model.mode)
  end

  def link_to_edit
    link_to(
      t('edit'),
      edit_register_path(model),
      {
        :remote       => true,
        :class        => 'start_modal btn btn-primary btn-rounded btn-labeled fa fa-cog',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end




end