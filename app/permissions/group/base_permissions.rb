class Group::BasePermissions
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
    setting :readings do
      setting :retrieve, ALL
    end

  end

  setting :meters, reader: true do
    setting :retrieve, ALL
    setting :update, NONE
    setting :delete, NONE
    setting :registers, reader: true do
      setting :retrieve, ALL
    end
  end

  setting :managers, reader: true do
    setting :retrieve, ALL
    setting :update, NONE
    setting :delete, NONE
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
