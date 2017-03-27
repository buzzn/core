class BankAccountResource < Buzzn::EntityResource

  model BankAccount

  attributes  :holder,
              :bank_name,
              :bic,
              :iban,
              :direct_debit

  # TODO make bank_name and bic derived from iban and not store them in DB
end

# TODO get rid of the need of having a Serializer class
class BankAccountSerializer < BankAccountResource
  def self.new(*args)
    super
  end
end
