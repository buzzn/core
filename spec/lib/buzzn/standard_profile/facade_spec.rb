# coding: utf-8
require 'buzzn/standard_profile/facade'

describe Buzzn::Discovergy::Facade do

  # make this specific to be sure to have this set even when running manually via rspec - could be deleted if not needed anymore.
  before :all do
    t = Time.local(2016, 7, 2, 10, 5, 0)
    Timecop.travel(t)
  end

  let(:meter) { Fabricate(:meter) }


  it 'gets readings' do |spec|
    facade = Buzzn::Discovergy::Facade.new
    interval = Buzzn::Interval.day(Time.now.to_i*1000)
    response = facade.power_chart('slp', interval)

  end




end
