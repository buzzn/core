require 'buzzn/discovergy/data_source'

describe Buzzn::StandardProfile::DataSource do

  describe 'slp' do

    it 'power_value' do |spec|
      energy_milliwatt_hour = 0
      berlin_time = Time.find_zone('Berlin')
      timestamp = berlin_time.local(2015,1,1)

      365.times do |i|
        reading = Fabricate(:reading,
                            source: 'slp',
                            timestamp: timestamp,
                            energy_milliwatt_hour: energy_milliwatt_hour,
                            power_milliwatt: 930*1000 )
        energy_milliwatt_hour += 19000*1000
        timestamp += 1.day
      end

      data_source = Buzzn::StandardProfile::DataSource.new
      energy_chart = data_source.power_value('slp', berlin_time.local(2015,4,1,12))

    end

  end

end
