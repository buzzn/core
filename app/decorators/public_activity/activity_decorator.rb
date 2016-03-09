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
    when 'friendship_request.create'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-question fa-2x timeline-circle" )
      end
    when 'friendship_request.reject'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-remove fa-2x timeline-circle" )
      end
    when 'friendship.create'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-chain fa-2x timeline-circle" )
      end
    when 'friendship.cancel'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-chain-broken fa-2x timeline-circle" )
      end


    when 'metering_point.create'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-plus-square fa-2x timeline-circle")
      end

    when 'metering_point.update'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-refresh fa-2x timeline-circle")
      end

    when 'metering_point.destroy'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-minus-square fa-2x timeline-circle")
      end



    when 'metering_point_user_request.create'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-question fa-2x timeline-circle")
      end

    when 'metering_point_user_request.reject'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-remove fa-2x timeline-circle")
      end

    when 'metering_point_user_invitation.create'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-question fa-2x timeline-circle")
      end

    when 'metering_point_user_invitation.reject'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-remove fa-2x timeline-circle")
      end

    when 'metering_point_user_membership.create'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-chain fa-2x timeline-circle")
      end

    when 'metering_point_user_membership.cancel'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-chain-broken fa-2x timeline-circle")
      end



    when 'group.create'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-plus-square fa-2x timeline-circle")
      end

    when 'group.update'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-refresh fa-2x timeline-circle")
      end

    when 'group.destroy'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-minus-square fa-2x timeline-circle")
      end

    when 'group.joined'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-group fa-2x timeline-circle")
      end



    when 'group_metering_point_membership.create'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-group fa-2x timeline-circle")
      end


    when 'comment.create'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-comment fa-2x timeline-circle")
      end

    when 'comment.liked'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-comment fa-2x timeline-circle")
      end

    when 'device.create'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-plus-square fa-2x timeline-circle")
      end

    when 'device.destroy'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-minus-square fa-2x timeline-circle")
      end

    when 'metering_point_user_membership.create'
      h.content_tag :div, :class => "timeline-icon bg-info" do
        h.content_tag(:i, '', :class => "fa fa-user-plus fa-2x timeline-circle")
      end
    end
  end

end


