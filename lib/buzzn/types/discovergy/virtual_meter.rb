require_relative 'meter'

# see POST/GET/DELETE VirtualMeter on https://api.discovergy.com/docs

class Types::Discovergy::VirtualMeter < Types::Discovergy::Meter

  def to_path; :virtual_meter; end

  class Get < Types::Discovergy::VirtualMeter
    include Types::Discovergy::Get
  end

  class Post < Types::Discovergy::VirtualMeter
    include Types::Discovergy::Post

    option :meter_ids_plus, Types::Strict::Array.member(Types::Strict::String)
    option :meter_ids_minus, Types::Strict::Array.member(Types::Strict::String), optional: true

    protected

    def attributes
      attr = super
      attr[:meterIdsPlus] = attr.delete(:meter_ids_plus)
      attr[:meterIdsMinus] = attr.delete(:meter_ids_minus)
      attr
    end
  end

  class Delete < Types::Discovergy::VirtualMeter
    include Types::Discovergy::Delete
  end
end
