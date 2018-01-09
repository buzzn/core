require_relative '../discovergy'
require_relative '../../../types/discovergy'
require_relative '../../../discovergy'

class Services::Datasource::Discovergy::OptimizedGroup

  include Import['service.datasource.discovergy.api']
  include Types::Discovergy

  def verify(group)
    local  = local(group).collect { |m| m.product_serialnumber }.sort.uniq
    remote = remote(group).collect { |m| m.serialNumber }.sort.uniq
    if local == remote
      true
    else
      diff = local - remote
      puts "Verifying the optimized group failed, there's a difference between Discovergy's and our list: #{diff}"
      false
    end
  end

  def create(group)
    plus = []
    minus = []
    group.registers.consumption_production.each do |r|
      next unless r.meter.broker
      if r.label.production?
        plus << r.meter.broker.external_id
      else
        minus << r.meter.broker.external_id
      end
    end

    ::Meter::Discovergy.transaction do
      query = VirtualMeter::Post.new(meter_ids_plus: plus,
                                     meter_ids_minus: minus)
      result = process(query)
      meter = ::Meter::Discovergy.create(group: group,
                                         product_serialnumber: result.serialNumber)
      Broker::Discovergy.create(meter: meter)
      meter
    end
  end

  def update(group)
    delete(group)
    create(group)
  end

  def delete(group)
    meter = discovergy_meter(group)
    ::Meter::Discovergy.transaction do
      process(VirtualMeter::Delete.new(meter: meter))
      meter.delete
    end
  end

  def remote(group)
    if meter = discovergy_meter(group)
      query = VirtualMeter::Get.new(meter: meter)
      process(query)
    else
      []
    end
  end

  def local(group)
    group.registers.consumption_production.collect do |register|
       register.meter if register.meter.broker
    end.compact.uniq
  end

  private

  def discovergy_meter(group)
    ::Meter::Discovergy.where(group: group).first
  end

  def process(query)
    api.request(query)
  end
end
