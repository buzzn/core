require_relative 'localpool'

module Contract
  class LocalpoolPowerTaker < Localpool

    def pdf_generators
      [
        Pdf::LsnA1,
        Pdf::LsnA2
      ]
    end

    def check_contract_number
      if self.contract_number.nil?
        self.contract_number = self.localpool.localpool_processing_contract.contract_number
      end
      self.check_contract_number_addition
    end

    def contexted_tariffs
      Service::Tariffs.data(self.tariffs)
    end

    def current_payment
      x = payments.current == [] ? nil : payments.current
      if x.is_a? Contract::Payment::ActiveRecord_AssociationRelation
        x.first
      else
        x
      end
    end

    def current_tariff
      now = Date.today
      current = nil
      self.contexted_tariffs.each do |tariff|
        if tariff.begin_date <= now && (tariff.end_date.nil? || tariff.end_date >= now)
          current = tariff.tariff
        end
      end
      current
    end

  end
end
