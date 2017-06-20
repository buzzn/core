class UserPermissions
  extend Dry::Configurable

  SELF = [:self].freeze
  NONE = [].freeze

  setting :create, NONE, reader: true
  setting :retrieve, SELF, reader: true
  setting :update, SELF, reader: true
  setting :delete, NONE, reader: true
end
