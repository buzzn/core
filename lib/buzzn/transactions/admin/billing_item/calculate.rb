require_relative '../billing_item'
require_relative '../../../schemas/transactions/admin/billing_item/update'

#If a begin_reading or an end_reading of a billing_item is missing, it can be calculated. 
#Therefor the share of total consumption is calculated according to the number of days that have passed by the time of the required reading. 
class Transactions::Admin::BillingItem::Calculate < Transactions::Base

  validate :schema
  check :authorize, with: :'operations.authorization.update'
  tee :check_valid
  tee :calculate_begin_reading
  tee :calculate_end_reading
  around :db_transaction
  map :persist, with: :'operations.action.update'

  def schema
    Schemas::Transactions::Admin::BillingItem::Calculate
  end

  def check_valid(resource:, params:)
    if resource.status != 'open'
      raise Buzzn::ValidationError.new({billing: ['billing is locked']}, resource.object)
    end
  end

  def calculate_begin_reading(resource:, params:, **)
    unless params[:begin_date].nil?
      if params[:raw_value].nil?
        start_date_billing = resource.billing.begin_date
        end_date_billing = resource.billing.end_date
        register = resource.register.object
        date = params[:begin_date]
        unless start_date_billing.nil? || end_date_billing.nil? || date.nil? || register.nil?
          params[:begin_reading] = calculate_reading(start_date_billing, end_date_billing, date, resource.register)
        end
      end
    end
  end

  def calculate_end_reading(resource:, params:, **)
    unless params[:end_date].nil?
      if params[:raw_value].nil?
        start_date_billing = resource.billing.begin_date
        end_date_billing = resource.billing.end_date
        register = resource.register.object
        date = params[:end_date]
        unless start_date_billing.nil? || end_date_billing.nil? || date.nil? || register.nil?
          params[:end_reading] = calculate_reading(start_date_billing, end_date_billing, date, resource.register)
        end
      end
    end
  end

  def calculate_reading(start_date_billing, end_date_billing, date, resource)
    reading_service = Import.global('services.reading_service')
    register = resource.object
    if register.readings.find_by(date: date).nil?
      begin
        reading_start_date_billing = reading_service.get(register, start_date_billing, :precision => 2.days)
        reading_end_date_billing = reading_service.get(register, end_date_billing, :precision => 2.days)
      rescue Buzzn::DataSourceError
        raise Buzzn::ValidationError.new({reading: ['billing must have a begin and end reading']})
      end
      if reading_start_date_billing.nil? || reading_end_date_billing.nil?
        raise Buzzn::ValidationError.new({reading: ['billing must have a begin and end reading']})
      else
        consumption_total = reading_end_date_billing.to_a.max_by(&:value).raw_value - reading_start_date_billing.to_a.max_by(&:value).raw_value
        consumption = (date - start_date_billing)/(end_date_billing - start_date_billing) * consumption_total
        reading_value = reading_start_date_billing.to_a.max_by(&:value).raw_value + consumption
        attrs = {
          raw_value: reading_value.to_i,
          date: date,
          status: 'Z86',
          reason: 'PMR',
          read_by: 'BUZZN',
          quality: '67',
          unit: 'Wh',
          source: 'MAN'
        }
        begin
          reading = Transactions::Admin::Reading::Create.new.(resource: resource, params: attrs)
          reading.value!.object
        rescue => e
          raise Buzzn::ValidationError.new({register: ['there exists already a reading for this register at this date and for this reason']}, register)
        end
      end
    else
      register.readings.find_by(date: date)
    end
  end
end
