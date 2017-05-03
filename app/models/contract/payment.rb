module Contract
  class Payment < ActiveRecord::Base

    #source constants
    CALCULATED = 'calculated'
    TRANSFERRED = 'transferred'

    #cycle constants
    MONTHLY = 'monthly'
    YEARLY = 'yearly'
    ONCE = 'once'

    def self.all_sources
      @source ||= [CALCULATED, TRANSFERRED]
    end

    def self.all_cycles
      @cycle ||= [MONTHLY, YEARLY, ONCE]
    end

    belongs_to :contracts, class_name: Base, foreign_key: :contract_id

    validates :begin_date, presence: true
    validates :end_date, presence: false
    # assume all money-data is without taxes!
    validates :price_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :cycle, presence: true, inclusion: {in: all_cycles}
    validates :source, presence: true, inclusion: {in: all_sources}

    scope :in_year, -> (year) { where('begin_date <= ?', Date.new(year, 12, 31))
                                  .where('end_date > ? OR end_date IS NULL', Date.new(year, 1, 1)) }
    scope :at, -> (timestamp) { where('begin_date <= ?', timestamp)
                                  .where('end_date >= ? OR end_date IS NULL', timestamp + 1.second) }

    scope :by_source, lambda {|*sources|
      sources.each do |source|
        raise ArgumentError.new('Undefined constant "' + source + '". Only use constants defined by Contract::Payment.all_sources.') unless self.all_sources.include?(source)
      end
      self.where("source in (?)", sources)
    }

    # TODO cycle enum ? is cycle a required attribute ?
    # TODO source enum ?

    def self.readable_by(*args)
      where(Contract::Base.readable_by(*args).where("payments.contract_id = contracts.id").select(1).limit(1).exists)
    end
  end
end
