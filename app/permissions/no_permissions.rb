class NoPermissions
  extend Dry::Configurable

  NONE = [].freeze

  setting :create, NONE, reader: true
  setting :retrieve, NONE, reader: true
  setting :update, NONE, reader: true
  setting :delete, NONE, reader: true
end
