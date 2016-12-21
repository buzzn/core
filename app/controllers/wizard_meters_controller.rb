class WizardMetersController  < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js


  def wizard
    @register = Register::Base.find(params[:register_id])
    @meter = Meter.new
    @discovergy_broker = DiscovergyBroker.new
  end

  def wizard_update
    Meter.transaction do
      @register = Register::Base.find(params[:register_id])
      if params[:meter][:existing_meter] == t('add_existing_meter')
        @meter = Meter.find(params[:meter][:meter_id])
        @meter.registers << @register
        if @meter.registers.collect(&:contracts).collect(&:metering_point_operators).flatten.any?
          @contract = @meter.registers.collect(&:contracts).collect(&:metering_point_operators).flatten.first
          @contract2 = Contract.new
          @contract2.organization = @contract.organization
          @contract2.username = @contract.username
          @contract2.password = @contract.password
          @contract2.mode = @contract.mode
          @contract2.price_cents = @contract.price_cents
          @contract2.register = @register
          if @contract2.save
            flash[:notice] = t('meter_created_successfully')
          else
            flash[:error] = t('could_not_create_meter_due_to_problems_while_establishing_data_connection')
            raise ActiveRecord::Rollback
          end
        end
      else
        @meter = Meter.new(meter_params)
        @meter.registers << @register
        if @meter.save
          if params[:meter][:smartmeter] == "1"
            #meter valid, now check contract

            @contract = Contract.new(contract_params)
            @contract.mode = 'metering_point_operator_contract'
            @contract.price_cents = 0
            @contract.register = @register
            if @contract.organization.slug == 'buzzn-metering' ||
               @contract.organization.buzzn_metering?
              @contract.username = 'team@localpool.de'
              @contract.password = 'Zebulon_4711'
            elsif @contract.organization.slug == 'mysmartgrid'
              @contract.username = params[:contract][:sensor_id]
              @contract.password = params[:contract][:x_token]
            end

            if @contract.save && @register.meter.save
              if @register.smart?
                flash[:notice] = t("your_credentials_have_been_checked_and_are_valid", register: @register.name)
              else
                @contract.errors.add(:password, I18n.t("wrong_username_and_or_password"))
                @contract.errors.add(:username, I18n.t("wrong_username_and_or_password")) #TODO: check via ajax
                flash[:error] = t('your_credentials_have_been_checked_and_are_invalid', register: @register.name)
              end
            else
              flash[:error] = t('could_not_create_meter_due_to_problems_while_establishing_data_connection')
              raise ActiveRecord::Rollback
            end

          else
            flash[:notice] = t('meter_created_successfully')
          end
        else
          flash[:error] = t('could_not_create_meter_due_to_problems_while_saving_data')
          raise ActiveRecord::Rollback
        end
      end
    end
  end

  def edit_wizard
    @meter = Meter.find(params[:meter_id])
    @register = Register::Base.find(params[:register_id])
    @discovergy_broker = @meter.discovergy_broker || DiscovergyBroker.new
  end

  def edit_wizard_update
    Meter.transaction do
      @meter = Meter.find(params[:meter_id])
      @register = Register::Base.find(params[:register_id])
      @meter.manufacturer_product_serialnumber = params[:meter][:manufacturer_product_serialnumber]
      @meter.manufacturer_name = params[:meter][:manufacturer_name]

      if @meter.save
        if params[:meter][:smartmeter] == "1"
          #meter valid, now check contract
          if !@meter.discovergy_broker
            organization = Organization.find(credential_params[:organization])
            @discovergy_broker = DiscovergyBroker.new(
              mode: @register.input? ? 'in' : 'out',
              external_id: "EASYMETER_#{meter_params[:manufacturer_product_serialnumber]}",
              provider_login: (organization.slug == 'buzzn-metering' || organization.buzzn_systems?) ? 'team@localpool.de' : credential_params[:provider_login],
              provider_password: (organization.slug == 'buzzn-metering' || organization.buzzn_systems?) ? 'Zebulon_4711' : credential_params[:provider_password],
              resource: @meter
            )
          else
            @discovergy_broker = @meter.discovergy_broker
          end

          if !@discovergy_broker.new_record?
            @discovergy_broker.provider_login = params[:meter][:discovergy_broker][:provider_login]
            @discovergy_broker.password = params[:meter][:discovergy_broker][:provider_password]
          end

          if @discovergy_broker.save && @meter.save
            if @register.smart?
              flash[:notice] = t("your_credentials_have_been_checked_and_are_valid", register: @register.name)
            else
              @discovergy_broker.errors.add(:provider_password, I18n.t("wrong_username_and_or_password"))
              @discovergy_broker.errors.add(:provider_login, I18n.t("wrong_username_and_or_password")) #TODO: check via ajax
              flash[:error] = t('your_credentials_have_been_checked_and_are_invalid', register: @register.name)
            end
          else
            flash[:error] = t('error_while_saving_data')
            raise ActiveRecord::Rollback
          end

        else
          flash[:notice] = t('data_saved_successfully')
        end
      else
        flash[:error] = t('error_while_saving_data')
        raise ActiveRecord::Rollback
      end
    end
  end


  private

  def meter_params
    params.require(:meter).permit(:id, :register_id, :manufacturer_product_serialnumber, :manufacturer_name, :registers)
  end

  def credential_params
    params.require(:meter).require(:discovergy_broker).permit( :id, :organization, :provider_login, :provider_password)
  end

end
