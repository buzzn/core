class FriendshipRequestDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  decorates_association :sender
  decorates_association :receiver
  decorates_association :profile

end