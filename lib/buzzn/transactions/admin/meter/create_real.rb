require_relative '../../../schemas/transactions/admin/meter/create_real'

class Transactions::Admin::Meter::CreateReal < Transactions::Base

  validate :schema
  tee :registers_schema
  check :authorize, with: 'operations.authorization.create'
  around :db_transaction
  tee :create_or_find_metering_point_id
  add :create_meter, with: 'operations.action.create_item'
  tee :create_registers
  map :result

  def schema
    Schemas::Transactions::Admin::Meter::CreateReal
  end

  def registers_schema(params:, **)
    validation_errors = { :registers => [] }
    params[:registers].each_with_index do |r, index|
      if r[:id].nil?
        schema = Schemas::Transactions::Admin::Register::CreateMeta
      else
        schema = Schemas::Transactions::Assign
      end
      result = schema.call(r)
      if result.success?
        Success(params[:registers][index] = result.output)
      else
        validation_errors[:registers][index] = result.errors
      end
    end

    unless validation_errors[:registers].empty?
      raise Buzzn::ValidationError.new(validation_errors)
    end
  end

  def create_or_find_metering_point_id(params:, **)
    metering_location_id = params.delete(:metering_location_id)
    if metering_location_id
      params[:metering_location] = Meter::MeteringLocation.find_by_metering_location_id(metering_location_id) ||
                                   Meter::MeteringLocation.create(metering_location_id: metering_location_id)
    end
  end

  def create_meter(params:, resource:, **)
    registers = params.delete(:registers)
    meter_resource = Meter::RealResource.new(
      *super(resource, params)
    )
    params.clear
    params[:registers] = registers
    meter_resource
  end

  def create_registers(params:, create_meter:, **)
    params[:registers].each_with_index do |r, index|
      if r[:id].nil?
        market_location_id = r.delete(:market_location_id)
        unless market_location_id.nil?
          r[:market_location] = Register::MarketLocation.find_by_market_location_id(market_location_id) ||
                                Register::MarketLocation.create(market_location_id: market_location_id)
        end
        meta = Register::Meta.create(r)
      else
        begin
          meta = Register::Meta.find(r[:id])
        rescue ActiveRecord::RecordNotFound
          raise Buzzn::ValidationError.new(registers: { index: [:id => 'object does not exist'] })
        end
      end

      Register::Real.create(meter: create_meter.object,
                            meta: meta)
    end
  end

  def result(create_meter:, **)
    create_meter.object.reload
    create_meter
  end

end
