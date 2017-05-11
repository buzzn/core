# coding: utf-8
module Group
  class Localpool < Base

    def metering_point_operator_contract
      Contract::MeteringPointOperator.where(localpool_id: self).first
    end

    def localpool_processing_contract
      Contract::LocalpoolProcessing.where(localpool_id: self).first
    end

    def localpool_power_taker_contracts
      Contract::LocalpoolPowerTaker.where(localpool_id: self)
    end

    def contracts
      Contract::Localpool.joins(:localpool).where(localpool: self)
    end

    def users
      User.where(contracts
                  .where('contracts.signing_user_id = users.id or contracts.customer_id = users.id or contracts.contractor_id = users.id')
                  .select(1)
                  .exists)
    end

    def organizations
      Organization.where(contracts
                          .where('contracts.customer_id = organizations.id or contracts.contractor_id = organizations.id')
                  .select(1)
                  .exists)
    end

    def meters      
      Meter::Base.where(id: registers.select(:meter_id))
    end

    has_many :addresses, as: :addressable, dependent: :destroy
    has_many :prices, dependent: :destroy
    has_many :billing_cycles, dependent: :destroy

    after_create :create_corrected_grid_registers

    # use first address as main address
    # TODO: maybe improve this so that the user can select between all addresses
    def main_address
      self.addresses.order("created_at ASC").first
    end

    def create_corrected_grid_registers
      # TODO: maybe add obis attribute and formula parts if it makes sense
      if registers.by_label(Register::Base::GRID_CONSUMPTION_CORRECTED).size == 0
        meter = Meter::Virtual.create!(register: Register::Virtual.new( mode: :in,
                                                                        name: 'ÜGZ Bezug korr.',
                                                                        label: Register::Base::GRID_CONSUMPTION_CORRECTED,
                                                                        readable: 'members'))
        registers << meter.register
      end
      if registers.by_label(Register::Base::GRID_FEEDING_CORRECTED).size == 0
        meter = Meter::Virtual.create!(register: Register::Virtual.new( mode: :out,
                                                                        name: 'ÜGZ Einspeisung korr.',
                                                                        label: Register::Base::GRID_FEEDING_CORRECTED,
                                                                        readable: 'members'))
        registers << meter.register
      end
    end
  end
end
