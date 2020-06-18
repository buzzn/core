require_relative '../admin'

class Transactions::Admin::PowerTakerExport < Transactions::Base

  add :get_local_power_takers

  # Filters the active power takers of each pool, and puts them into a dict along with the groups info.
  class PowerTakerFilter

    include Enumerable

    def initialize(localpools)
      @localpools = localpools
    end

    # Returns the overall electricity consumption.
    #
    # @param meter [Meter::Discovergy] The power taker's meters.
    # @param contract [Contract::LocalPowerTaker]  The power taker's contract.
    # @return [dict] Containing the power takers personal info and his meter product serial number.
    def serialize_power_taker(meter, contract)
      {
        id_platform: contract.contact.id,
        first_name: contract.contact.first_name,
        name: contract.contact.last_name,
        gender: contract.contact.prefix.to_s.upcase,
        mail: contract.contact.email,
        meter_id: meter.product_serialnumber
      }
    end

    def each
      @localpools.each do |l|
        registers = l.meters.select {|m| m.datasource == 'discovergy'}
                     .flat_map(&:registers)
                     .reject(&:decomissioned?)

        unless registers.any?
          next
        end

        production = registers.select(&:production?)
                              .map(&:meter)
                              .map(&:product_serialnumber)
                              .uniq
        unless production.any?
          next
        end

        consumption_common = registers.select {|r| r.register_meta&.consumption_common?}
                                      .map(&:meter)
                                      .map(&:product_serialnumber)
                                      .uniq
        unless consumption_common.any?
          next
        end
        power_takers = registers.flat_map {|r| r.contracts.map {|c| {meter: r.meter, contract: c}}}
                                .reject {|p| p[:contract].contact.nil?}
                                .select {|p| p[:contract].active?}

        yield ({ id_platform: l.id,
                 name: l.name,
                 production: production,
                 consumption: consumption_common,
                 power_takers: power_takers.map {|p| serialize_power_taker(p[:meter], p[:contract])}})

      end
    end

  end

  def get_local_power_takers(localpools:)
    PowerTakerFilter.new(localpools).to_a
  end

end
