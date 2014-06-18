class PublicActivity::ActivityDecorator < Draper::Decorator
  include Draper::LazyHelpers
  decorates PublicActivity::Activity
  delegate_all

  def key_icon
    case model.key
    when 'location.create'
      t('update_metering_point')

    when 'location.update'
      t('update_metering_point')

    when 'location.delete'
      t('update_metering_point')

    when 'metering_point.create'
      t('create_metering_point')

    when 'metering_point.update'
      h.content_tag :span, :class => "fa-stack fa-lg" do
        content_tag(:i, '', :class => "fa fa-square-o fa-stack-2x") +
        content_tag(:i, '', :class => "fa fa-home fa-stack-1x")
      end

    when 'metering_point.delete'
      t('delete_metering_point')

    end
  end

end