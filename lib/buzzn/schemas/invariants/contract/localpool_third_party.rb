require_relative 'localpool'

module Schemas
  module Invariants
    module Contract
      LocalpoolThirdParty = Schemas::Support.Form(Localpool) do
        required(:customer) { none? }
        required(:contractor) { none? }
      end
    end
  end
end
