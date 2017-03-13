module Contract
  class LocalpoolProcessing < Contract::Base

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
      if contractor
        errors.add(:contractor, MUST_BE_BUZZN_SYSTEMS) unless contractor == Organization.buzzn_systems
      end
    end

  end
end
