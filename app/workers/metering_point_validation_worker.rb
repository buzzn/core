class MeteringPointValidationWorker
  include Sidekiq::Worker

  def perform(metering_point_id)
    @metering_point = MeteringPoint.find(metering_point_id)
    @meter = @metering_point.meter
    if @metering_point && @meter && (@metering_point.metering_point_operator_contract || @metering_point.group.metering_point_operator_contract)
      @mpoc = @metering_point.metering_point_operator_contract

      discovergy = Discovergy.new(@mpoc.username, @mpoc.password, "EASYMETER_#{@meter.manufacturer_product_serialnumber}")
      result     = discovergy.call()
      if result['status'] == 'ok'
        @meter.update_columns(smart: true)
        first_day_init(metering_point_id)
      else
        @meter.update_columns(smart: false)
      end
    else
      @meter.update_columns(smart: false)
    end
  end

  def first_day_init(metering_point_id)
      @metering_point = MeteringPoint.find(metering_point_id)
      register        = @metering_point.registers.first # TODO not compatible with in_out smartmeter
      mpoc            = @metering_point.metering_point_operator_contract
      date            = Time.now.in_time_zone
      beginning       = date.beginning_of_day
      ending          = date
      (beginning.to_i .. ending.to_i).step(1.minutes) do |time|
        start_time = time * 1000
        end_time   = Time.at(time).end_of_minute.to_i * 1000
        MeterReadingUpdateWorker.perform_async(
                                                register.id,
                                                @metering_point.meter.manufacturer_product_serialnumber,
                                                mpoc.organization.slug,
                                                mpoc.username,
                                                mpoc.password,
                                                start_time,
                                                end_time
                                              )
      end
  end

end