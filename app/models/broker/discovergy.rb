class Broker::Discovergy < Broker::Base

  def self.modes
    [:in, :out, :in_out, :virtual]
  end

  def external_id
    case meter
    when Meter::Real
      "EASYMETER_#{meter.product_serialnumber}"
    when Meter::Virtual
      super
    else raise "unknown meter type: #{meter.class}"
    end
  end
end
