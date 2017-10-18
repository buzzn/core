require 'rspec/expectations'

RSpec::Matchers.define :be_session_expired_json do |expected|
  match do |actual|
    JSON.parse(actual.body) == {
      "error" => "This session has expired, please login again."
    } && actual.status == expected
  end
end

RSpec::Matchers.define :be_not_found_json do |expected, clazz, method = nil|
  match do |actual|
    method ||= 'bla-blub'
    JSON.parse(actual.body) == {
      "errors" => [
        {
          "detail"=>"#{clazz}: #{method} not found by User: #{$admin.id}" }
      ]
    } && actual.status == expected
  end
end

RSpec::Matchers.define :be_stale_json do |expected, instance|
  match do |actual|
    JSON.parse(actual.body) == {
      "errors" => [
        {
          "detail"=>"#{instance.class}: #{instance.id} was updated at: #{instance.updated_at}"
        }
      ]
    } && actual.status == expected
  end
end

RSpec::Matchers.define :be_denied_json do |expected, instance, user = nil|
  match do |actual|
    if instance.is_a?(Class)
      clazz = instance
      id = nil
    else
      clazz = instance.class
      id = "#{instance.id} "
    end
    JSON.parse(actual.body) == {
      "errors" => [
        {
          "detail"=>"retrieve #{clazz}: #{id}permission denied for User: #{(user || $user).id}"
        }
      ]
    } && actual.status == expected
  end
end
