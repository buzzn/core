class ProfileDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  decorates_association :friends
  decorates_association :received_friendship_requests
  decorates_association :user
  decorates_association :users
  decorates_association :device
  decorates_association :metering_points
  decorates_association :groups
  decorates_association :residents


  def link_to_edit
    link_to(
      t('edit'),
      edit_profile_path(model),
      {
        :remote       => true,
        :class        => 'start_modal btn btn-primary btn-labeled fa fa-cog',
        'data-toggle' => "modal",
        'data-target' => '#myModal'
      })
  end



end