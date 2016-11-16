class GroupRegisterRequestDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all

  decorates_association :user
  decorates_association :register
  decorates_association :group

end