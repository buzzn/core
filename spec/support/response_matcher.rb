require 'rspec/expectations'

RSpec::Matchers.define :has_nested_json do |*attrs|

  def next_current(current, attr)
    current = current[attr.to_s]
    if attr.to_sym == :array && current
      current.first
    else
      current
    end
  end

  match do |actual|
    current = actual
    attrs.all? do |attr|
      current = next_current(current, attr)
      !current.nil?
    end
  end

  failure_message do |actual|
    current = actual
    path = attrs.reject do |attr|
      current = next_current(current, attr) if current
      current.nil?
    end
    path << (attrs - path).first
    "expected #{attrs.join('->')} to have nested element but missing: #{path.join('->')}"
  end
end

RSpec::Matchers.define :be_session_expired_json do |expected|
  match do |actual|
    JSON.parse(actual.body) == {
      'error' => 'This session has expired, please login again.'
    } && actual.status == expected
  end
end

RSpec::Matchers.define :be_not_found_json do |expected, clazz, method = nil|
  match do |actual|
    method ||= 'bla-blub'
    JSON.parse(actual.body) == {
      'errors' => [
        {
          'detail'=>"#{clazz}: #{method} not found by User: #{$admin.id}" }
      ]
    } && actual.status == expected
  end
end

RSpec::Matchers.define :be_stale_json do |expected_code, instance|
  match do |actual|
    JSON.parse(actual.body) == {
      'errors' => [
        {
          'detail'=>"#{instance.class}: #{instance.id} was updated at: #{instance.updated_at}"
        }
      ]
    } && actual.status == expected_code
  end

  failure_message do |response|
    "Expected status code #{expected_code} but was #{response.status}. Response body is: #{JSON.parse(actual.body)}"
  end
end

RSpec::Matchers.define :be_denied_json do |expected, instance, user: nil, prefix: 'retrieve'|
  match do |actual|
    if instance.is_a?(Class)
      clazz = instance
      id = nil
    else
      clazz = instance.class
      id = "#{instance.id} "
    end
    JSON.parse(actual.body) == {
      'errors' => [
        {
          'detail'=>"#{prefix} #{clazz}: #{id}permission denied for User: #{(user || $user).id}"
        }
      ]
    } && actual.status == expected
  end
end
