class ValidatesCredentialsWorker
  include Sidekiq::Worker

  def perform(model_name, model_id)

    case model_name
    when 'MeteringPointOperatorContract'
      @mpoc = MeteringPointOperatorContract.find(model_id)

      if @mpoc.organization.slug == 'discovergy' || @mpoc.organization.slug == 'buzzn-metering'
        api_call = Discovergy.new(@mpoc.username, @mpoc.password).meters
        if api_call['status'] == 'ok'
          @mpoc.update_columns(valid_credentials: true)
          if @mpoc.group
            @mpoc.group.metering_points.each do |metering_point|
              metering_point.meter.save
            end
          end
          if @mpoc.metering_point
            @mpoc.metering_point.meter.save
          end
        else
          @mpoc.update_columns(valid_credentials: false)
        end
      end
    end

  end
end