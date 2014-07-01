class UserDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all
  decorates_association :profile
end