module Contract
  class GroupGapContractTariff < ActiveRecord::Base

    self.table_name = :groups_gap_contract_tariffs

    belongs_to :group
    belongs_to :tariff

  end
end
