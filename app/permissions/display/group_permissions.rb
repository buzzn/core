class Display::GroupPermissions
  extend Dry::Configurable

  ALL = [:anonymous].freeze
  NONE = [].freeze

  setting :create, NONE, reader: true
  setting :retrieve, ALL, reader: true
  setting :update, NONE, reader: true
  setting :delete, NONE, reader: true

  setting :mentors, reader: true do
    setting :retrieve, ALL
  end

  setting :registers, reader: true do
    setting :retrieve, ALL
  end

  setting :scores, reader: true do
    setting :retrieve, ALL
  end

  setting :bubbles, reader: true do
    setting :retrieve, ALL
  end

  setting :charts, reader: true do
    setting :retrieve, ALL
  end
end
