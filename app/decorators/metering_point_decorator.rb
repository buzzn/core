class MeteringPointDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all
  decorates_association :devices
  decorates_association :meter
  decorates_association :users
  decorates_association :location
  decorates_association :group
  decorates_association :contracts
  decorates_association :registers
  decorates_association :electricity_supplier_contracts
  decorates_association :metering_service_provider_contracts
  decorates_association :metering_point_operator_contracts
  decorates_association :distribution_system_operator_contracts
  decorates_association :transmission_system_operator_contracts


  def chart(resolution='day_to_hours', chart_type='column_chart')
    if resolution == 'day_to_hours'
      date_format = '{value: %H:%M}'
    elsif resolution == 'hour_to_minutes'
      date_format = '{value: %H:%M:%S}'
    elsif resolution == 'month_to_days'
      date_format = '{value: %e. %b}'
    elsif resolution == 'year_to_months'
      date_format = '{value: %Y}'
    end
    colors = []
    model.registers.map(&:mode).each do |mode|
      case mode
      when 'in'
        colors << '#00f'
      when 'out'
        colors << '#f00'
      else
        colors << '#0f0'
      end
    end
    h.send(
      chart_type,
      chart_metering_point_path(model, resolution: resolution),
      colors: colors,
      library: {

        tooltip:{
          pointFormat: "{point.y:,.2f} kWh"
        },
        exporting: {
          enabled: false
        },

        xAxis: {
          type: 'datetime',
          dateTimeLabelFormats: {
            minute: "%H:%M" #TODO not working.
          },
          labels: {
            format: date_format,
            align: 'right',
            enabled: true,
            style: {
              color: '#FFF'
            }
          }
        },
        yAxis: {
          gridLineWidth: 0,
          labels: {
            enabled: true,
            style: {
              color: '#FFF'
            }
          }
        }
      }
    )
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


  def name_long
    case mode
    when 'in'
      name
    when 'in_out'
      "#{t(mode)} #{generator_type_names}-#{name}"
    when 'out'
      "#{t(mode)} #{generator_type_names} #{name}"
    end
  end


  def generator_type_names
    names = []
    generator_types = devices.map {|i| i.category }.uniq
    generator_types.each do |type|
      names << type if type
    end
    return names.join(', ')
  end





  def link_to_show
    link_to model.name, metering_point_path(model)
  end


  def link_to_edit
    link_to(
      t('edit'),
      edit_metering_point_path(model),
      {
        :remote       => true,
        :class        => 'start_modal btn btn-primary btn-rounded btn-labeled fa fa-cog',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end








  def edit_users
    link_to(
      content_tag(:i, nil, class: 'fa fa-plus-circle fa-3x fa-inverse'),
      edit_users_metering_point_path(model),
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal',
        'data-tooltip'  => "true",
        'title'         => t("add_user"),
      })
  end



  def edit_devices
    link_to(
      content_tag(:i, nil, class: 'fa fa-plus-circle fa-3x fa-inverse'),
      edit_devices_metering_point_path(model),
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal',
        'data-tooltip'  => "true",
        'title'         => t("add_devices"),
      })
  end



  def new_register
    link_to(
      content_tag(:i, nil, class: 'fa fa-plus-circle fa-3x fa-inverse'),
      new_register_path(metering_point_id: model.id),
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal',
        'data-tooltip'  => "true",
        'title'         => t("add_register"),
      })
  end


  def new_metering_point_operator_contract
    link_to(
      content_tag(:i, nil, class: 'fa fa-plus-circle fa-3x fa-inverse'),
      new_metering_point_operator_contract_path(metering_point_id: model.id),
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal',
        'data-tooltip'  => "true",
        'title'         => t("add_metering_point_operator_contract"),
      })
  end



  def new_meter
    link_to(
      content_tag(:i, nil, class: 'fa fa-plus-circle fa-3x fa-inverse'),
      new_meter_path(metering_point_id: model.id),
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal',
        'data-tooltip'  => "true",
        'title'         => t("add_meter"),
      })
  end




  def new_sub_metering_point
    link_to(
      content_tag(:i, nil, class: 'fa fa-plus-circle fa-3x fa-inverse'),
      metering_point_wizard_metering_points_path(parent_metering_point_id: model.id),
      {
        :remote         => true,
        :class          => 'btn start_modal',
        'data-toggle'   => 'modal',
        'data-target'   => '#myModal',
        'data-tooltip'  => "true",
        'title'         => t("add_sub_metering_point"),
      })
  end




end
