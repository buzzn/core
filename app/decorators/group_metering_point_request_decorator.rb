class GroupMeteringPointRequestDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  decorates_association :user
  decorates_association :metering_point
  decorates_association :group

end