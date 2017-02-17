class WizardMetersController  < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js


  def wizard
    @register = Register::Base.find(params[:register_id])
    @meter = Meter::Base.new
    @broker = Broker::Base.new
  end

  def wizard_update
    Meter::Base.transaction do
      @register = Register::Base.find(params[:register_id])
      if params[:meter][:existing_meter] == t('add_existing_meter')
        @meter = Meter::Base.find(params[:meter][:meter_id])
        @meter.registers << @register
        if @meter.registers.collect(&:contracts).collect(&:metering_point_operators).flatten.any?
          @contract = @meter.registers.collect(&:contracts).collect(&:metering_point_operators).flatten.first
          @contract2 = Contract::Base.new
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
        @meter = Meter::Base.new(meter_params)
        @meter.registers << @register
        if @meter.save
          if params[:meter][:smartmeter] == "1"
            #meter valid, now check contract

            @contract = Contract::Base.new(contract_params)
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
    @meter = Meter::Base.find(params[:meter_id])
    @register = Register::Base.find(params[:register_id])
    @broker = @meter.broker || Broker::Base.new
  end

  def edit_wizard_update
    Meter::Base.transaction do
      @meter = Meter::Base.find(params[:meter_id])
      @register = Register::Base.find(params[:register_id])
      @meter.manufacturer_product_serialnumber = meter_params[:manufacturer_product_serialnumber]
      @meter.manufacturer_name = meter_params[:manufacturer_name]

      if @meter.save
        if meter_params[:smartmeter] == "1"
          #meter valid, now check contract
          organization = Organization.find(credential_params[:organization])
          if !@meter.broker

            if organization.slug == 'buzzn-metering' || organization.buzzn_systems? || organization.slug == 'discovergy'
              @broker = Broker::Discovergy.new(
               mode: @register.input? ? 'in' : 'out',
                external_id: "EASYMETER_#{meter_params[:manufacturer_product_serialnumber]}",
                provider_login: (organization.slug == 'buzzn-metering' || organization.buzzn_systems?) ? 'team@localpool.de' : credential_params[:provider_login],
                provider_password: (organization.slug == 'buzzn-metering' || organization.buzzn_systems?) ? 'Zebulon_4711' : credential_params[:provider_password],
                resource: @meter
              )
            else
              @broker = Broker::MySmartGrid.new(
                mode: @register.input? ? 'in' : 'out',
                provider_login: credential_params[:sensor_id],
                provider_password: credential_params[:x_token],
                resource: @meter
              )
            end
          else
            @broker = @meter.broker
            if organization.slug == 'buzzn-metering' || organization.buzzn_systems? || organization.slug == 'discovergy'
              @broker.provider_login = credential_params[:provider_login]
              @broker.provider_password = credential_params[:provider_password]
            else
              @broker.provider_login = credential_params[:sensor_id]
              @broker.provider_password = credential_params[:x_token]
            end
          end



          if @broker.save && @meter.save
            if @register.smart?
              flash[:notice] = t("your_credentials_have_been_checked_and_are_valid", register: @register.name)
            else
              @broker.errors.add(:provider_password, I18n.t("wrong_username_and_or_password"))
              @broker.errors.add(:provider_login, I18n.t("wrong_username_and_or_password")) #TODO: check via ajax
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

  def broker_class
    if !params[meter_class][:broker].nil?
      :broker
    elsif !params[meter_class][:discovergy_broker].nil?
      :discovergy_broker
    elsif !params[meter_class][:my_smart_grid_broker].nil?
      :my_smart_grid_broker
    end
  end

  def meter_class
    if !params[:meter_real].nil? && params[:meter_virtual].nil?
      :meter_real
    elsif params[:meter_real].nil? && !params[:meter_virtual].nil?
      :meter_virtual
    end
  end

  def meter_params
    params.require(meter_class).permit(:id, :register_id, :manufacturer_product_serialnumber, :manufacturer_name, :registers, :smartmeter)
  end

  def credential_params
    params.require(meter_class).require(broker_class).permit( :id, :organization, :provider_login, :provider_password, :sensor_id, :x_token)
  end

end
