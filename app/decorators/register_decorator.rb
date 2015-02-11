class RegisterDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  def panel_mode_class
    case model.mode
    when 'in'
      'danger'
    when 'out'
      'primary'
    end
  end

end