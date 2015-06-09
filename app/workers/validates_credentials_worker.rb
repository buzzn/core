class ValidatesCredentialsWorker
  include Sidekiq::Worker

  def perform(contract_id)
      @contract = Contract.find(contract_id)

      if @contract.mode == 'metering_point_operator_contract'
        if @contract.organization.slug == 'discovergy' || @contract.organization.slug == 'buzzn-metering'
          api_call = Discovergy.new(@contract.username, @contract.password).meters
          if api_call['status'] == 'ok'
            @contract.update_columns(valid_credentials: true)
            self.send_notification_credentials(@contract.id, true)
            if @contract.group
              @contract.group.metering_points.each do |metering_point|
                metering_point.meter.save
              end
            end
            if @contract.metering_point && @contract.metering_point.meter
              @contract.metering_point.meter.save
            end
          else
            @contract.update_columns(valid_credentials: false)
            self.send_notification_credentials(@contract.id, false)
          end
        end
      end

  end

  def send_notification_credentials(contract_id, valid)
    contract = Contract.find(contract_id)
    if contract && contract.contracting_party
      user = contract.contracting_party.user
      if valid
        user.send_notification("success", I18n.t("valid_credentials"), I18n.t("your_credentials_have_been_checked_and_are_valid", contract: contract.mode))
      else
        user.send_notification("danger", I18n.t("invalid_credentials"), I18n.t("your_credentials_have_been_checked_and_are_invalid", contract: contract.mode))
      end
    end
  end
end