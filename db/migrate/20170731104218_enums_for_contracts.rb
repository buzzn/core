class EnumsForContracts < ActiveRecord::Migration
  def up
    create_enum :contract_status, *Contract::Base::STATUS
    create_enum :taxation, *Contract::Base::TAXATIONS

    remove_column :contracts, :status
    rename_column :contracts, :renewable_energy_law_taxation, :tax
    add_column :contracts, :status, :contract_status, index: true, default: Contract::Base::ONBOARDING, null: true
    add_column :contracts, :renewable_energy_law_taxation, :taxation, index: true, null: true
    Contract::Base.all.each do |c|
      c.active!
      case c.tax
      when 'full'
        c.full!
      when 'reduced'
        c.reduced!
      when NilClass
      else
        warn "unknown taxation #{c.tax}"
      end
    end

    remove_column :contracts, :tax
  end
end
