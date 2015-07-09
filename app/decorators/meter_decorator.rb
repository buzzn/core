class MeterDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  decorates_association :metering_points

  def name
    "#{manufacturer_name} #{manufacturer_product_serialnumber}"
  end


  def link_to_edit
    link_to(
      t('edit_meter'),
      edit_meter_path(model),
      {
        :remote       => true,
        :class        => 'start_modal btn btn-primary btn-labeled fa fa-cog',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end



end