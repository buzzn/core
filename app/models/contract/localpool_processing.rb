module Contract
  class LocalpoolProcessing < Localpool

    def self.new(*args)
      a = super
      # HACK to fix the problem that the type gets not set by AR
      a.type ||= a.class.to_s
      a
    end

    belongs_to :localpool, class_name: 'Group::Localpool'
    has_one :tax_data, class_name: 'Contract::TaxData', foreign_key: :contract_id
    delegate :subject_to_tax,
             :sales_tax_number,
             :tax_number,
             :tax_rate,
             :creditor_idenfication,
             :retailer,
             :provider_permission,
             to: :tax_data, allow_nil: true

    validates :localpool, presence: true
    validates :begin_date, presence: true

    def validate_invariants
      super
      if contractor
        errors.add(:contractor, MUST_BE_BUZZN_SYSTEMS) unless contractor == Organization.buzzn_systems
      end
    end

  end
end
