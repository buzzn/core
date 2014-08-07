class PublicActivity::ActivityDecorator < Draper::Decorator
  include Draper::LazyHelpers
  decorates PublicActivity::Activity
  delegate_all

  decorates_association :owner
  decorates_association :recipient
  decorates_association :group
  decorates_association :profile
  decorates_association :metering_point
  decorates_association :location

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


    when 'group.create'
      h.content_tag(:i, '', :class => "fa fa-plus-square fa-2x")

    when 'group.update'
      h.content_tag(:i, '', :class => "fa fa-refresh fa-2x")

    when 'group.destroy'
      h.content_tag(:i, '', :class => "fa fa-minus-square fa-2x")

    when 'group.joined'
      h.content_tag(:i, '', :class => "fa fa-group fa-2x")


    when 'friendship.create'
      h.content_tag(:i, '', :class => "fa fa-chain fa-2x" )
    end
  end

end


