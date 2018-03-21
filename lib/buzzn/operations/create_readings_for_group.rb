require_relative '../operations'

#
# Fetch readings from Discovergy and create Reading objects for the every meter passed in
#
class Operations::CreateReadingsForGroup

  include Dry::Transaction::Operation

  include Import['services.datasource.discovergy.single_reading']

  def call(group:, date_time:)
    readings = request_readings(group, date_time)
    if readings.nil? || readings.empty?
      # It's Ok(ish) if there are no readings from Discovergy, we realized.
      # Mixed groups and those without smart meters won't have some.
      # We still want the creation of the billing cycle to succeed, so that manual
      # readings can be created.
      msg = "No readings from Discovergy (result was #{readings.inspect})"
      return Success(msg)
    end
    result = readings.map { |register_id, reading_value| create_reading(register_id, reading_value, date_time) }
    Success(result)
  end

  private

  # returns a hash of register_id -> reading values
  def request_readings(group, date_time)
    single_reading.all(group, date_time)
  end

  def create_reading(register_id, reading_value, date_time)
    attrs = {
      register_id:  register_id,
      date:         date_time.to_date,
      raw_value:    reading_value,
      value:        reading_value,
      reason:       :regular_reading,
      unit:         :watt_hour,
      quality:      :read_out,
      read_by:      :buzzn,
      source:       :smart,
      status:       :z86
    }
    existing_reading = Reading::Single.find_by(attrs.slice(:date, :register_id))
    existing_reading ? existing_reading : Reading::Single.create!(attrs)
  end

end
