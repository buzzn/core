require_relative '../operations'

#
# Fetch readings from Discovergy and create Reading objects for the every meter passed in
#
class Operations::CreateReadingsForGroup

  include Dry::Transaction::Operation

  include Import['services.datasource.discovergy.single_reading']

  def call(group:, date_time:)
    readings = request_readings(group, date_time)
    Left('Couldn\'t fetch readings') unless readings
    result = readings.map { |register_id, reading_value| create_reading(register_id, reading_value, date_time) }
    Right(result)
  end

  private

  # returns a hash of register_id -> reading values
  def request_readings(group, date_time)
    single_reading.all(group, date_time)
  end

  def create_reading(register_id, reading_value, date_time)
    Reading::Single.create!(
      register_id:  register_id,
      date:         date_time.to_date,
      raw_value:    reading_value,
      value:        reading_value,
      reason:       :regular_reading,
      unit:         :watt_hour,
      quality:      :read_out,
      source:       :smart,
      status:       :z86
    )
  end

end
