class MeterReactivateWorker
  include Sidekiq::Worker

  def perform(meter_id)
    @meter = Meter.find(meter_id)
    @mpoc  = @meter.metering_points.first.metering_point_operator_contract
    request = Discovergy.new(@mpoc.username, @mpoc.password).raw_with_power(@meter.manufacturer_product_serialnumber)

    if request['status'] == 'ok'
      if request['result'].any? && @meter.metering_points.any? && @meter.smart

        last  = Reading.last_by_metering_point_id(@meter.metering_points.first.id)['timestamp']
        now   = Time.now.in_time_zone.utc

        if (last.to_i .. now.to_i).size < 1.hour
          @meter.update_columns(online: true) # meter is back online if readings not older than 1 hour
        else
          Sidekiq::Client.push({
           'class' => MeterUpdateWorker,
           'queue' => :low,
           'args' => [
                      @meter.metering_points_modes_and_ids,
                      @meter.manufacturer_product_serialnumber,
                      @mpoc.organization.slug,
                      @mpoc.username,
                      @mpoc.password,
                      last.to_i,
                      now.to_i
                     ]
          })
        end
      end
    end
  end
end