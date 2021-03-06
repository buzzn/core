require_relative '../discovergy'
require_relative '../../../types/discovergy'

class Services::Datasource::Discovergy::OptimizedGroup

  include Import['services.datasource.discovergy.api']
  include Types::Discovergy

  def initialize(**)
    super
    @logger = Buzzn::Logger.new(self)
  end

  def verify(group)
    local  = local(group).collect { |m| m.product_serialnumber }.sort.uniq
    remote = remote(group).collect { |m| m.serialNumber }.sort.uniq
    if local == remote
      true
    else
      diff_left = local - remote
      diff_right = remote - local
      @logger.warn { "Verifying the optimized group failed, there's a difference between Discovergy's #{diff_right} and our list #{diff_left}" }
      false
    end
  end

  def discovergy_id(meter)
    "EASYMETER_#{meter.product_serialnumber}"
  end

  def reject_register(r)
    !r.meter.discovergy? || r.is_a?(Register::Substitute) || !r.decomissioned_at.nil?
  end

  def create(group)
    plus = []
    minus = []
    group.registers.each do |r|
      next if reject_register(r)
      if r.production? || r.meta.grid_consumption?
        plus << discovergy_id(r.meter)
      elsif r.consumption? || r.meta.grid_feeding?
        minus << discovergy_id(r.meter)
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
    #delete(group)
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
    group.registers.to_a.reject {|r| reject_register(r)}.collect {|x| x.meter}.uniq
  end

  private

  def discovergy_meter(group)
    group.meters_discovergy.order(:created_at).last
  end

  def process(query)
    api.request(query)
  end

end
