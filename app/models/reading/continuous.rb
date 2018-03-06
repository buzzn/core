require 'mongoid'
module Reading
  class Continuous

    include Mongoid::Document
    include ReadingEnums

    def self.model_name; ActiveModel::Name.new(self, nil, 'readings'); end

    field :contract_id
    field :register_id
    field :timestamp, type: DateTime
    field :energy_milliwatt_hour, type: Integer
    field :power_milliwatt,       type: Integer
    field :reason
    field :source
    field :quality
    field :load_course_time_series, type: Float
    field :state
    field :meter_serialnumber

    index(register_id: 1)
    index(timestamp: 1)
    index(register_id: 1, timestamp: 1)
    index(register_id: 1, source: 1)

    validate :energy_milliwatt_hour_has_to_grow, if: :user_input?
    def user_input?; source == USER_INPUT; end

    validates :reason, inclusion: { in: reasons }
    validates :quality, inclusion: { in: qualities }
    validates :source, inclusion: { in: sources}
    validates :register_id, presence: true
    validates :timestamp, presence: true
    validates :energy_milliwatt_hour, presence: true
    validates :power_milliwatt, presence: false
    validates :meter_serialnumber, presence: true
    validates_uniqueness_of :timestamp, scope: [:register_id, :reason], message: 'already available for given register and reason'

    scope :in_year, -> (year) { where(:timestamp.gte => Time.new(year, 1, 1)).where(:timestamp.lte => Time.new(year, 12, 31, 23, 59, 59)) }
    scope :at, -> (timestamp) do
      timestamp = case timestamp
                  when DateTime
                    timestamp.to_time
                  when Time
                    timestamp
                  when Date
                    timestamp.to_time
                  when Integer
                    Time.at(timestamp)
                  else
                    raise ArgumentError.new("timestamp not a Time or Fixnum or Date: #{timestamp.class}")
                  end
      where(:timestamp.gte => timestamp).where(:timestamp.lt => timestamp + 1.second)
    end

    scope :by_register_id, -> (register_id) { where(register_id: register_id) }

    scope :by_reason, lambda {|*reasons|
      reasons.each do |reason|
        raise ArgumentError.new('Undefined constant "' + reason + '". Only use constants defined by Reading.reasons.') unless self.reasons.include?(reason)
      end
      self.where(:reason.in => reasons)
    }

    scope :without_reason, lambda {|*reasons|
      reasons.each do |reason|
        raise ArgumentError.new('Undefined constant "' + reason + '". Only use constants defined by Reading.reasons.') unless self.reasons.include?(reason)
      end
      self.where(:reason.nin => reasons)
    }

    def register
      Register::Base.find(self.register_id) if self.register_id
    end

    def energy_milliwatt_hour_has_to_grow
      reading_before = last_before_user_input
      reading_after = next_after_user_input
      if !reading_before.nil? && reading_before[:energy_milliwatt_hour] > energy_milliwatt_hour
        self.errors.add(:energy_milliwatt_hour, 'is lower than the last one:' + (reading_before[:energy_milliwatt_hour]/1000000).to_s)
      end
      if !reading_after.nil? && reading_after[:energy_milliwatt_hour] < energy_milliwatt_hour
        self.errors.add(:energy_milliwatt_hour, 'is greater than the next one:' + (reading_after[:energy_milliwatt_hour]/1000000).to_s)
      end
    end

    def self.all_by_register_id(register_id)
      pipe = [
        { '$match' => {
            register_id: {
              '$in' => [register_id]
            }
          }
        },
        { '$sort' => {
            timestamp: 1
          }
        }
      ]
      return Reading::Continuous.collection.aggregate(pipe).to_a
    end

    def self.all_by_register_id_and_source(register_id, source)
      pipe = [
        { '$match' => {
            register_id: {
              '$in' => [register_id]
            },
            source:{
              '$in' => [source]
            }
          }
        },
        { '$sort' => {
            timestamp: 1
          }
        }
      ]
      return Reading::Continuous.collection.aggregate(pipe).to_a
    end

    def last_before_user_input
      pipe = [
        { '$match' => {
            register_id: {
              '$in' => [register_id]
            },
            source:{
              '$in' => ['user_input']
            },
            timestamp: {
              '$lt'  => timestamp.utc
            }
          }
        },
        { '$sort' => {
            timestamp: -1
          }
        },
        { '$limit' => 1 }
      ]
      return Reading::Continuous.collection.aggregate(pipe).first
    end

    def next_after_user_input
      pipe = [
        { '$match' => {
            register_id: {
              '$in' => [register_id]
            },
            source:{
              '$in' => ['user_input']
            },
            timestamp: {
              '$gt'  => timestamp.utc
            }
          }
        },
        { '$sort' => {
            timestamp: -1
          }
        },
        { '$limit' => 1 }
      ]
      return Reading::Continuous.collection.aggregate(pipe).first
    end

  end
end
