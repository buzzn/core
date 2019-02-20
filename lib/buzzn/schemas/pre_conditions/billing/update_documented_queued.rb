require_relative 'update'

module Schemas::PreConditions::Billing::Update

  DocumentedQueued = Schemas::Support.Schema do

    required(:status).eql?('queued')

    required(:contract).schema do
      required(:customer).schema do
        required(:contact_email).filled(:str?, :email?)
      end
    end

  end

end
