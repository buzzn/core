class Broker::Discovergy < Broker::Base

  def self.modes
    [:in, :out, :in_out, :virtual]
  end

  def external_id
    case meter
    when Meter::Real
      "EASYMETER_#{meter.product_serialnumber}"
    else
      "VIRTUAL_#{meter.product_serialnumber}"
    end
  end
end
