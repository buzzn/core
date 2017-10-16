module Contract
  class LocalpoolProcessing < Localpool

    def self.new(*args)
      a = super
      # HACK to fix the problem that the type gets not set by AR
      a.type ||= a.class.to_s
      a
    end

    belongs_to :localpool, class_name: Group::Localpool

    validates :localpool, presence: true
    validates :first_master_uid, presence: true
    validates :second_master_uid, presence: false
    validates :begin_date, presence: true

    def validate_invariants
      super
      errors.add(:contractor, MUST_BE_BUZZN_SYSTEMS) if contractor && !contractor.buzzn_systems?
    end
  end
end
