class ValidatesCredentialsWorker
  include Sidekiq::Worker

  def perform(contract_id)
      @contract = Contract.find(contract_id)

      if @contract.mode == 'metering_point_operator_contract'
        if @contract.organization.slug == 'discovergy' || @contract.organization.slug == 'buzzn-metering'
          api_call = Discovergy.new(@contract.username, @contract.password).meters
          if api_call['status'] == 'ok'
            @contract.update_columns(valid_credentials: true)
            if @contract.group
              @contract.group.metering_points.each do |metering_point|
                metering_point.meter.save
              end
            end
            if @contract.metering_point
              @contract.metering_point.meter.save
            end
          else
            @contract.update_columns(valid_credentials: false)
          end
        end
      end

  end
end