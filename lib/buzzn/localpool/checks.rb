module Buzzn::Localpool
  class Checks
    class << self
      # This method iterates over all consumption registers in a LCP and checks if each register has
      # a running contract at each time between the beginning of the LCP and now.
      # input params:
      #   localpool: The Group::Localpool for which the check has to be done
      # returns:
      #   MissingLsnCheckResultSet: Object, that contains all information about missing contracts on different registers
      def check_missing_lsn_contracts(localpool)
        result = MissingLsnCheckResultSet.new()
        localpool_start_date = find_object_or_error('localpool is missing a processing_contract') do
          localpool.localpool_processing_contract.begin_date
        end
        localpool.registers.by_label(Register::Base::CONSUMPTION).each do |register|
          date_of_first_reading = find_object_or_error("no reading found for register #{register.name}") do
            Reading.by_register_id(register.id).sort('timestamp': 1).first.timestamp.to_date
          end
          all_contracts_on_register = register.contracts.localpool_power_takers_and_other_suppliers.order('begin_date ASC')
          if all_contracts_on_register.size > 0
            i = 0
            all_contracts_on_register.each do |contract|
              contract_begin_date = contract.begin_date
              contract_end_date = contract.end_date
              check_first_contract(i, date_of_first_reading, contract_begin_date, result, register)
              check_middle_contract(i, contract_end_date, all_contracts_on_register, result, register)
              check_last_contract(i, contract_end_date, all_contracts_on_register, result, register)
              i += 1
            end
          else
            result.add(MissingLsnCheckResult.new(register, date_of_first_reading, nil))
          end
        end
        return result
      end

      # This method checks if the first contract of a register matches with the first available reading for this register
      # input params:
      #   i: Integer used as loop counter which tells the method if the contract is the first one
      #   date_of_first_reading: Date of the first reading of a register
      #   contract_begin_date: The contract's begin_date
      #   result: MissingLsnCheckResultSet which will contain all the information about missing contracts
      #   register: The register for which the check is done
      # returns:
      #   MissingLsnCheckResultSet: Object, that contains all information about missing contracts on different registers
      def check_first_contract(i, date_of_first_reading, contract_begin_date, result, register)
        if i == 0 && date_of_first_reading < contract_begin_date
          result.add(MissingLsnCheckResult.new(register, date_of_first_reading, contract_begin_date))
        end
      end

      # This method checks if a register has a gap between two or more contracts and throws an error
      # if it detects an overlap between two contracts
      # input params:
      #   i: Integer used as loop counter when iterating over all contracts
      #   contract_end_date: The contract's end_date
      #   all_contracts_on_register: Array containing all contracts for a register
      #   result: MissingLsnCheckResultSet which will contain all the information about missing contracts
      #   register: The register for which the check is done
      # returns:
      #   MissingLsnCheckResultSet: Object, that contains all information about missing contracts on different registers
      def check_middle_contract(i, contract_end_date, all_contracts_on_register, result, register)
        if all_contracts_on_register.size - 1 > i
          next_contract_begin_date = all_contracts_on_register[i + 1].begin_date
          if next_contract_begin_date < contract_end_date
            raise CheckError.new("multiple contracts at register #{register.name} at a time")
          elsif next_contract_begin_date > contract_end_date + 1.day # maybe some contract ends at May 31st and the next begins at June 1st
            result.add(MissingLsnCheckResult.new(register, contract_end_date, next_contract_begin_date))
          end
        end
      end

      # This method checks if the last contract of a register has already expired and needs an actual one
      # input params:
      #   i: Integer used as loop counter when iterating over all contracts
      #   contract_end_date: The contract's end_date
      #   all_contracts_on_register: Array containing all contracts for a register
      #   result: MissingLsnCheckResultSet which will contain all the information about missing contracts
      #   register: The register for which the check is done
      # returns:
      #   MissingLsnCheckResultSet: Object, that contains all information about missing contracts on different registers
      def check_last_contract(i, contract_end_date, all_contracts_on_register, result, register)
        if !contract_end_date.nil? && contract_end_date < Time.current && i == all_contracts_on_register.size - 1
          result.add(MissingLsnCheckResult.new(register, contract_end_date, nil))
        end
      end

      # This method creates a new LSN contract for the given customer
      # input params:
      #   customer: ContractingParty which will be uses as customer for the new contract
      #   register: The register which is attached to the new contract
      #   begin_date: The Date of the new contract's beginning
      #   end_date: The Date of the new contract's ending
      def assign_default_lsn(customer, register, begin_date, end_date)
        status = end_date.nil? ? Contract::Base::RUNNING : Contract::Base::EXPIRED
        contract_number = register.group.localpool_processing_contract.contract_number
        Contract::LocalpoolPowerTaker.create!(status: status,
                                              begin_date: begin_date,
                                              end_date: end_date,
                                              forecast_kwh_pa: 0,
                                              terms_accepted: true,
                                              power_of_attorney: true,
                                              contract_number: contract_number,
                                              contract_number_addition: Contract::LocalpoolPowerTaker.where(contract_number: contract_number).order('contract_number_addition DESC').first.contract_number_addition + 1,
                                              register: register,
                                              localpool_id: register.group.id, # TODO: this is optional. make it mandatory?
                                              renewable_energy_law_taxation: Contract::RenewableEnergyLawTaxation::REDUCED,
                                              signing_user: register.group.managers.first, # TODO: this must be the owner of the LCP in the future
                                              signing_date: begin_date,
                                              customer: customer,
                                              contractor: register.group.localpool_processing_contract.customer,
                                              energy_consumption_before_kwh_pa: 0,
                                              down_payment_before_cents_per_month: 0)
      end

      # This method executes the given block and throws a custom CheckError if something goes wrong
      # Especially it checks if somewhere in the object tree some method is called on a nil object and
      # then a CheckError with a custom message can be given to the end user
      # input params:
      #   error_message: The custom error message (string) that will be used when throwing the CheckError
      #   &block: The block that will be executed
      # returns:
      #   The result of the given block or raises an Error if something goes wrong
      def find_object_or_error(error_message, &block)
        begin
          block.call
        rescue StandardError => error
          if error.message.include?('undefined method') && error.message.include?('for nil:NilClass')
            raise CheckError.new(error_message)
          else
            raise error
          end
        end
      end

    end
  end

  class CheckError < StandardError
  end

  class MissingLsnCheckResult
    attr_reader :register, :begin_date, :end_date

    def initialize(register, begin_date, end_date)
      unless register.is_a?(Register::Base) || begin_date.is_a?(Date) || end_date.is_a?(Date)
        raise ArgumentError.new('arguments must be Register::Base, Date, Date')
      end
      @register = register
      @begin_date = begin_date
      @end_date = end_date
    end
  end

  class MissingLsnCheckResultSet
    attr_reader :all_results

    def initialize()
      @all_results = []
    end

    def add(missing_lsn_check_result)
      unless missing_lsn_check_result.is_a?(Buzzn::Localpool::MissingLsnCheckResult)
        raise ArgumentError.new('argument must be Buzzn::Localpool::MissingLsnCheckResult')
      end
      @all_results << missing_lsn_check_result
    end
  end
end