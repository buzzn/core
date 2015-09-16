class UserDecorator < Draper::Decorator
  include Draper::LazyHelpers
  include DeviseInvitable::Inviter
  delegate_all
  decorates_association :profile
  decorates_association :metering_points
  decorates_association :location
end