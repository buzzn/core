class PersonPermissions
  extend Dry::Configurable

  SELF = [:self].freeze
  NONE = [].freeze

  setting :create, NONE, reader: true
  setting :retrieve, SELF, reader: true
  setting :update, SELF, reader: true
  setting :delete, NONE, reader: true

  setting :address, reader: true do
    setting :create, SELF
    setting :retrieve, SELF
    setting :update, SELF
    setting :delete, SELF
  end

  setting :bank_accounts, reader: true do
    setting :create, SELF
    setting :retrieve, SELF
    setting :update, SELF
    setting :delete, SELF
  end
end
