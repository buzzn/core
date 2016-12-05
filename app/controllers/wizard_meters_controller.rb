class WizardMetersController  < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js


  def wizard
    @register = Register::Base.find(params[:register_id])
    @meter = Meter.new
    @contract = Contract.new
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
    @contract = @meter.registers.first.contracts.metering_point_operators.first || Contract.new
  end

  def edit_wizard_update
    Meter.transaction do
      @meter = Meter.find(params[:meter_id])
      @register = Register::Base.find(params[:register_id])
      #@register_ids = params[:meter][:register_ids]
      @meter.manufacturer_product_serialnumber = params[:meter][:manufacturer_product_serialnumber]
      @meter.manufacturer_name = params[:meter][:manufacturer_name]
      #@meter.registers = @register_ids.each{|id| Register::Base.find(id)}

      if @meter.save
        if params[:meter][:smartmeter] == "1"
          #meter valid, now check contract

          if params[:contract_id] == "" || params[:contract_id] == nil
            @contract = Contract.new(contract_params)
          else
            @contract = Contract.find(params[:contract_id])
          end
          if !@contract.new_record?
            @contract.organization_id = params[:meter][:contract][:organization_id]
            @contract.username = params[:meter][:contract][:username]
            @contract.password = params[:meter][:contract][:password]
          end
          @contract.mode = 'metering_point_operator_contract'
          @contract.price_cents = 0
          @contract.register = @register
          if @contract.organization.slug == 'buzzn-metering' ||
             @contract.organization.buzzn_metering?
            @contract.username = 'team@localpool.de'
            @contract.password = 'Zebulon_4711'
          elsif @contract.organization.slug == 'mysmartgrid'
            @contract.username = params[:meter][:contract][:sensor_id]
            @contract.password = params[:meter][:contract][:x_token]
          end

          if @contract.save && @meter.save
            if @register.smart?
              flash[:notice] = t("your_credentials_have_been_checked_and_are_valid", register: @register.name)
            else
              @contract.errors.add(:password, I18n.t("wrong_username_and_or_password"))
              @contract.errors.add(:username, I18n.t("wrong_username_and_or_password")) #TODO: check via ajax
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

  def contract_params
    params.require(:meter).require(:contract).permit( :id, :organization_id, :username, :password)
  end

end
