require_relative 'last_reading'

# see GET Readings on https://api.discovergy.com/docs

module Types::Discovergy

  Resolution = Types::Strict::Symbol.enum(*%i(raw three_minutes fifteen_minutes one_hour one_day one_week one_month one_year))

  class Readings < Types::Discovergy::LastReading

    option :from, Types::Strict::Int
    option :to, Types::Strict::Int, optional: true
    option :resolution, Resolution, optional: true
    option :disaggregation, Types::Strict::Bool, optional: true

    def to_path; :readings; end

    class Get < Types::Discovergy::Readings
      include Types::Discovergy::Get
    end

  end
end
