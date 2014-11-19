class MeterInitWorker
  include Sidekiq::Worker

  def perform(meter_id)
    @meter = Meter.find(meter_id)

    if @meter.metering_point
      if @meter.metering_point.metering_point_operator_contract
        @mpoc = @meter.metering_point.metering_point_operator_contract
        if @mpoc.organization.slug == 'discovergy' || @mpoc.organization.slug == 'buzzn-metering'
          request = Discovergy.new(@mpoc.username, @mpoc.password).raw(@meter.manufacturer_product_serialnumber)
          if request['status'] == 'ok'
            @meter.update_columns(smart: true)
            @meter.update_columns(online: request['result'].any?)

            if @meter.registers.any? && @meter.smart && @meter.online
              if Reading.latest_by_register_id(@meter.registers.first.id)
                logger.warn "Meter:#{@meter.id} init reading already written"
              else
                @metering_point = @meter.metering_point
                @mpoc           = @meter.metering_point.metering_point_operator_contract
                if @metering_point && @mpoc
                  init_meter_id = @meter.id

                  start_time    = Time.now.in_time_zone.utc - 5.minutes # some meters are very slow to update
                  end_time      = Time.now.in_time_zone.utc

                  Sidekiq::Client.push({
                   'class' => MeterReadingUpdateWorker,
                   'queue' => :low,
                   'args' => [
                              @meter.registers_modes_and_ids,
                              @meter.manufacturer_product_serialnumber,
                              @mpoc.organization.slug,
                              @mpoc.username,
                              @mpoc.password,
                              start_time.to_i * 1000,
                              end_time.to_i * 1000,
                              init_meter_id
                             ]
                  })

                end
              end
            else
              logger.warn "Meter#{@meter.id}: is not posible to initialize. registers:#{@meter.registers.size}, smart:#{@meter.smart}, online:#{@meter.online}"
            end


          elsif request['status'] == "error"
            logger.error request
            @meter.update_columns(smart: false)
            @meter.update_columns(online: false)
          else
            logger.error request
          end
        else
          logger.warn "Meter:#{@meter.id} is not posible to validate. @metering_point:#{@metering_point}, @mpoc:#{metering_point.metering_point_operator_contract}"
          @meter.update_columns(smart: false)
          @meter.update_columns(online: false)
        end
      else
        logger.warn "Meter:#{@meter.id} has no metering_point_operator_contract"
      end
    else
      logger.warn "Meter:#{@meter.id} has no metering_point"
    end



  end
end