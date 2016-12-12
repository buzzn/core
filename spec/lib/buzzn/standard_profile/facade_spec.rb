# coding: utf-8
require 'buzzn/standard_profile/facade'

describe Buzzn::StandardProfile::Facade do

  describe 'SLP' do
    it 'day_to_minutes' do |spec|
      energy_milliwatt_hour = 0
      moscow_time = Time.find_zone('Moscow')
      timestamp = moscow_time.local(2015,1,1) # SLP for Moscow
      (24*4+1).times do |i|
        reading = Fabricate(:reading,
                            source: 'slp',
                            timestamp: timestamp,
                            energy_milliwatt_hour: energy_milliwatt_hour,
                            power_milliwatt: 930*1000 )
        energy_milliwatt_hour += 1300*1000
        timestamp += 15.minutes
      end

      interval  = Buzzn::Interval.day(moscow_time.local(2015,1,1))
      facade    = Buzzn::StandardProfile::Facade.new

      power_chart = facade.power_chart('slp', interval)
      expect(power_chart.count).to eq 97
      expect(power_chart.first['power_milliwatt']).to eq 930*1000
      expect(power_chart.first['energy_milliwatt']).to eq nil
      expect(power_chart.first['timestamp']).to eq moscow_time.local(2015,1,1)
      expect(power_chart.last['timestamp']).to eq moscow_time.local(2015,1,2)

      energy_chart = facade.energy_chart('slp', interval)
      expect(energy_chart.count).to eq 97
      # expect(energy_chart.first['power_milliwatt']).to eq nil
      # # expect(energy_chart.first['energy_milliwatt']).to eq 930*1000
      # expect(energy_chart.first['timestamp']).to eq @moscow_time.local(2015,1,1)
      # expect(energy_chart.last['timestamp']).to eq @moscow_time.local(2015,1,2)
    end

  end





end
