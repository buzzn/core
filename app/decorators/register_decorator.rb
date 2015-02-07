class RegisterDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def panel_mode_class
    case model.mode
    when 'in'
      'panel-danger'
    when 'out'
      'panel-primary'
    end
  end

end