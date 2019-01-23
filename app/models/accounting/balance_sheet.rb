module Accounting
  class BalanceSheet

    ATTRIBUTES = :contract, :total, :entries

    attr_accessor :contract

    def initialize(contract)
      self.contract = contract
    end

    def id
      nil
    end

    def created_at
      nil
    end

    def updated_at
      nil
    end

    def total
      accounting_service = Import.global('services.accounting')
      accounting_service.balance(self.contract)
    end

    def entries
      self.contract.accounting_entries
    end

    def attributes
      {}.tap do |hash|
        ATTRIBUTES.each do |a|
          hash[a.to_s] = self.send(a)
        end
      end
    end

  end
end
