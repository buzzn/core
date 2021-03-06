require_relative '../../../schemas/transactions/admin/meter/create_real'
require_relative '../meter'

class Transactions::Admin::Meter::CreateReal < Transactions::Admin::Meter

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
      if r.empty?
        next
      elsif r[:id].nil?
        schema = Schemas::Transactions::Admin::Register::CreateMeta
      else
        #if an id is given try to assign the existing meta with the given id 
        #unless the given name or label are different from the existing meta's name or label
        begin
          given_register = Register::Meta.find(r[:id])
          name = r[:name]
          label = r[:label]
          unless name.nil? || label.nil?
          #if no name or label is given, the existing meta with the given id should be assigned
            if given_register.name == name && given_register.label.casecmp?(label) 
              #if the given name and the given label are the same as the name and label of the existing meta with the given id, 
              #the existing meta should be assigned
              schema = Schemas::Transactions::Assign
            else
              #if the given name or the given label are different from the name or label of the existing meta with the given id, 
              #a new meta should be created
              r = {"name":name,"label":label}
              schema = Schemas::Transactions::Admin::Register::CreateMeta
            end
          else
            schema = Schemas::Transactions::Assign
          end
        rescue ActiveRecord::RecordNotFound
          raise Buzzn::ValidationError.new({registers: ['index does not exist']})
        end
        
        
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
      meta = if r.empty?
               nil
             elsif r[:id].nil?
               market_location_id = r.delete(:market_location_id)
               unless market_location_id.nil?
                 r[:market_location] = Register::MarketLocation.find_by_market_location_id(market_location_id) ||
                                       Register::MarketLocation.create(market_location_id: market_location_id)
               end
               Register::Meta.create(r)
             else
               begin
                 Register::Meta.find(r[:id])
               rescue ActiveRecord::RecordNotFound
                raise Buzzn::ValidationError.new({registers: ['index does not exist']})
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
