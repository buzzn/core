class MeteringPointDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all
  #decorates_association :meter
  decorates_association :devices


  def link_to_edit
    h.link_to(
      name,
      edit_metering_point_path(model),
      {
        remote: true,
        class: 'start_modal',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end


  def name
    case model.mode
    when 'up'
      "#{model.position} / #{t(model.mode)} #{t('for')} #{generator_type_names} #{model.address_addition}"
    when 'down'
      "#{model.position} / #{t(model.mode)} | #{model.address_addition}"
    when 'up_down'
      "#{model.position} / #{t(model.mode)}"
    when 'diff'
      "#{model.position} / #{t(model.mode)}"
    else
      "no mode"
    end
  end

  def generator_type_names
    names = []
    generator_types = model.devices.map {|i| i.generator_type }.uniq
    generator_types.each do |type|
      names << t("#{type}_short")
    end
    return names.join(', ')
  end

end
