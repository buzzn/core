require_relative '../localpool'

module Transactions::Admin::Contract::Localpool
  class CreateGapContracts < Transactions::Base

    validate :schema
    tee :localpool_schema
    tee :set_end_date, with: :'operations.end_date'
    tee :validate_dates
    add :calculated_ranges
    add :create_gap_contracts
    # return this somehow?
    map :wrap_up

    def schema
      Schemas::Transactions::Admin::Contract::Localpool::GapContracts::Create
    end

    def localpool_schema(localpool:, **)
      subject = Schemas::Support::ActiveRecordValidator.new(localpool.object)
      result = Schemas::PreConditions::Localpool::CreateLocalpoolGapContract.call(subject)
      unless result.success?
        raise Buzzn::ValidationError.new('localpool': result.errors)
      end
    end

    def validate_dates(localpool:, params:, **)
      if params[:begin_date] < localpool.start_date
        raise Buzzn::ValidationError.new('begin_date': 'must be after localpool.start_date')
      end
    end

    def calculated_ranges(params:, resource:, localpool:)

      localpool.object.register_metas.to_a.keep_if { |x| x.consumption? || x.grid_consumption? }.collect do |register_meta|
        installed_at     = (register_meta.registers.collect { |r| r.installed_at     }.reject(&:nil?).sort_by { |x| x.date }.first)&.date
        decomissioned_at = (register_meta.registers.collect { |r| r.decomissioned_at }.reject(&:nil?).sort_by { |x| x.date }.last)&.date

        date_range = ([params[:begin_date], installed_at || params[:begin_date]].max)..([params[:end_date], decomissioned_at || params[:end_date]]).min

        ranges = [ date_range ]
        register_meta.contracts.order(:begin_date).each do |contract|
          new_ranges = []
          ranges.each_with_index do |range, idx|
            #   [ range ]
            # [ contract ]
            if contract.begin_date <= range.first && (contract.end_date.nil? || contract.end_date >= range.last)
              ranges[idx] = range.first..range.first
              next
            end
            # [ range ]
            #     [   c   ]
            # [ r ]
            begin
            if contract.begin_date >= range.first && contract.begin_date < range.last && (contract.end_date.nil? || contract.end_date >= range.last)
              ranges[idx] = range.first..contract.begin_date
              next
            end
            #    [ range ]
            # [   c  ]
            #        [ r ]
            if contract.begin_date <= range.first && (contract.end_date.nil? || (contract.end_date > range.first && contract.end_date <= range.last))
              ranges[idx] = contract.end_date..range.last
              next
            end
            # [    range     ]
            #    [   c   ]
            if range.first <= contract.begin_date && (!contract.end_date.nil? && (range.last > contract.end_date))
              new_range = contract.end_date..range.last
              ranges[idx] = range.first..contract.begin_date
              new_ranges << new_range
              next
            end
            rescue Exception => e
              byebug.byebug
            end
          end
          ranges = ranges + new_ranges
          ranges.delete_if { |r| (r.last-r.first).zero? }
        end
        {
          register_meta: register_meta,
          ranges: ranges,
        }
      end
    end

    def create_gap_contracts(calculated_ranges:, resource:, localpool:, **)
      calculated_ranges.collect do |robj|
        robj[:ranges].collect do |range|
          params_contract = {
            register_meta: {
              id: robj[:register_meta].id,
            },
            begin_date: range.first,
            termination_date: range.first,
            last_date: range.last - 1.day # last_date!
          }
          result = Transactions::Admin::Contract::Localpool::CreateGapContract.new.(resource: resource, params: params_contract, localpool: localpool)
          result.value!
          # TODO raise something on error / rescue
        end
      end
    end

    def wrap_up(create_gap_contracts:, **)
      create_gap_contracts.flatten
    end

  end
end
