class PublicActivity::ActivityDecorator < Draper::Decorator
  include Draper::LazyHelpers
  decorates PublicActivity::Activity
  delegate_all

  decorates_association :owner

  def key_icon
    case model.key
    when 'location.create'
      h.content_tag(:i, '', :class => "fa fa-plus-square fa-2x")

    when 'location.update'
      h.content_tag(:i, '', :class => "fa fa-refresh fa-2x")

    when 'location.destroy'
      h.content_tag(:i, '', :class => "fa fa-minus-square fa-2x")


    when 'metering_point.create'
      h.content_tag(:i, '', :class => "fa fa-plus-square fa-2x")

    when 'metering_point.update'
      h.content_tag(:i, '', :class => "fa fa-refresh fa-2x")

    when 'metering_point.destroy'
      h.content_tag(:i, '', :class => "fa fa-minus-square fa-2x")

    end
  end

end


