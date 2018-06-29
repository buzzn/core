require_relative 'meter'

# see POST/GET/DELETE VirtualMeter on https://api.discovergy.com/docs

class Types::Discovergy::VirtualMeter < Types::Discovergy::Meter

  def to_path; :virtual_meter; end

  class Get < Types::Discovergy::VirtualMeter

    include Types::Discovergy::Get

  end

  class Post < Types::Discovergy::Base

    extend Dry::Initializer
    include Types::Discovergy::Post

    def to_path; :virtual_meter; end

    option :meter_ids_plus, Types::Strict::Array.of(Types::Strict::String)
    option :meter_ids_minus, Types::Strict::Array.of(Types::Strict::String), optional: true

    def to_query
      { meterIdsPlus: meter_ids_plus, meterIdsMinus: meter_ids_minus }.compact
    end

  end

  class Delete < Types::Discovergy::VirtualMeter

    include Types::Discovergy::Delete

  end

end
