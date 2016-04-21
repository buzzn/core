class WizardMetersController  < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js

  def meter
    @metering_point = MeteringPoint.find(params[:metering_point_id])
    @meter = Meter.new
  end

  def meter_update
    @metering_point = MeteringPoint.find(params[:metering_point_id])
    if params[:meter][:existing_meter] == t('add_existing_meter')
      @meter = Meter.find(params[:meter][:meter_id])
    else
      @meter = Meter.new(meter_params)
    end
    @meter.metering_points << @metering_point
    if @meter.metering_points.collect{|mp| mp.metering_point_operator_contract}.any? && params[:meter][:existing_meter] == t('add_existing_meter')
      @contract = @meter.metering_points.collect{|mp| mp.metering_point_operator_contract}.first
      @contract2 = Contract.new
      @contract2.organization = @contract.organization
      @contract2.username = @contract.username
      @contract2.password = @contract.password
      @contract2.mode = @contract.mode
      @contract2.price_cents = @contract.price_cents
      @contract2.metering_point = @metering_point
      if !@contract2.save
        render action: 'meter'
      end
    end
    if @meter.save
      if params[:meter][:smartmeter] == I18n.t('yes')
        redirect_to contract_wizard_meters_path(metering_point_id: @metering_point.id)
      else
        render action: 'update'
      end
    else
      render action: 'meter'
    end
  end

  def contract
    @metering_point = MeteringPoint.find(params[:metering_point_id])
    @contract = Contract.new
  end

  def contract_update
    @metering_point = MeteringPoint.find(params[:metering_point_id])
    if params[:cancel].nil? #TODO: submit form without "cancel" when hitting ENTER
      @contract = Contract.new(contract_params)
      @contract.mode = 'metering_point_operator_contract'
      @contract.price_cents = 0
      @contract.metering_point = @metering_point
      if @contract.organization.slug == 'buzzn-metering'
        @contract.username = 'team@localpool.de'
        @contract.password = 'Zebulon_4711'
      elsif @contract.organization.slug == 'mysmartgrid'
        @contract.username = params[:contract][:sensor_id]
        @contract.password = params[:contract][:x_token]
      end

      if @contract.save && @metering_point.meter.save
        if @metering_point.smart?
          flash[:notice] = t("your_credentials_have_been_checked_and_are_valid", metering_point: @metering_point.name)
          render action: 'update'
        else
          @contract.errors.add(:password, I18n.t("wrong_username_and_or_password"))
          @contract.errors.add(:username, I18n.t("wrong_username_and_or_password"))
          @contract.destroy
          render action: 'contract', metering_point_id: @metering_point.id
        end
      else
        render action: 'contract', metering_point_id: @metering_point.id
      end
    else
      if @metering_point.meter.destroy
        render action: 'update'
      end
    end
  end


  def wizard
    @metering_point = MeteringPoint.find(params[:metering_point_id])
    @meter = Meter.new
    @contract = Contract.new
  end

  def wizard_update
    Meter.transaction do
      @metering_point = MeteringPoint.find(params[:metering_point_id])
      if params[:meter][:existing_meter] == t('add_existing_meter')
        @meter = Meter.find(params[:meter][:meter_id])
        @meter.metering_points << @metering_point
        if @meter.metering_points.collect(&:contracts).collect(&:metering_point_operators).flatten.any?
          @contract = @meter.metering_points.collect(&:contracts).collect(&:metering_point_operators).flatten.first
          @contract2 = Contract.new
          @contract2.organization = @contract.organization
          @contract2.username = @contract.username
          @contract2.password = @contract.password
          @contract2.mode = @contract.mode
          @contract2.price_cents = @contract.price_cents
          @contract2.metering_point = @metering_point
          if @contract2.save
            flash[:notice] = t('meter_created_successfully')
          else
            flash[:error] = t('could_not_create_meter_due_to_problems_while_establishing_data_connection')
            raise ActiveRecord::Rollback
          end
        end
      else
        @meter = Meter.new(meter_params)
        @meter.metering_points << @metering_point
        if @meter.save
          if params[:meter][:smartmeter] == I18n.t('yes')
            #meter valid, now check contract

            @contract = Contract.new(contract_params)
            @contract.mode = 'metering_point_operator_contract'
            @contract.price_cents = 0
            @contract.metering_point = @metering_point
            if @contract.organization.slug == 'buzzn-metering'
              @contract.username = 'team@localpool.de'
              @contract.password = 'Zebulon_4711'
            elsif @contract.organization.slug == 'mysmartgrid'
              @contract.username = params[:contract][:sensor_id]
              @contract.password = params[:contract][:x_token]
            end

            if @contract.save && @metering_point.meter.save
              if @metering_point.smart?
                flash[:notice] = t("your_credentials_have_been_checked_and_are_valid", metering_point: @metering_point.name)
              else
                @contract.errors.add(:password, I18n.t("wrong_username_and_or_password"))
                @contract.errors.add(:username, I18n.t("wrong_username_and_or_password")) #TODO: check via ajax
                flash[:error] = t('your_credentials_have_been_checked_and_are_invalid', metering_point: @metering_point.name)
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
    @metering_point = MeteringPoint.find(params[:metering_point_id])
    @contract = @meter.metering_points.first.contracts.metering_point_operators.first || Contract.new
  end

  def edit_wizard_update
    Meter.transaction do
      @meter = Meter.find(params[:meter_id])
      @metering_point = MeteringPoint.find(params[:metering_point_id])
      #@metering_point_ids = params[:meter][:metering_point_ids]
      @meter.manufacturer_product_serialnumber = params[:meter][:manufacturer_product_serialnumber]
      @meter.manufacturer_name = params[:meter][:manufacturer_name]
      #@meter.metering_points = @metering_point_ids.each{|id| MeteringPoint.find(id)}

      if @meter.save
        if params[:meter][:smartmeter] == I18n.t('yes')
          #meter valid, now check contract

          if params[:contract_id] == ""
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
          @contract.metering_point = @metering_point
          if @contract.organization.slug == 'buzzn-metering'
            @contract.username = 'team@localpool.de'
            @contract.password = 'Zebulon_4711'
          elsif @contract.organization.slug == 'mysmartgrid'
            @contract.username = params[:meter][:contract][:sensor_id]
            @contract.password = params[:meter][:contract][:x_token]
          end

          if @contract.save && @meter.save
            if @metering_point.smart?
              flash[:notice] = t("your_credentials_have_been_checked_and_are_valid", metering_point: @metering_point.name)
            else
              @contract.errors.add(:password, I18n.t("wrong_username_and_or_password"))
              @contract.errors.add(:username, I18n.t("wrong_username_and_or_password")) #TODO: check via ajax
              flash[:error] = t('your_credentials_have_been_checked_and_are_invalid', metering_point: @metering_point.name)
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


  def edit_meter
    @meter = Meter.find(params[:meter_id])
  end

  def edit_meter_update
    @meter = Meter.find(params[:meter_id])
    @new_metering_point_ids = params[:meter][:metering_point_ids]
    @meter.manufacturer_product_serialnumber = params[:meter][:manufacturer_product_serialnumber]
    @meter.manufacturer_name = params[:meter][:manufacturer_name]
    @new_metering_point_ids.each do |metering_point_id|
      if !@meter.metering_point_ids.include?(metering_point_id)
        @meter.metering_point_ids << metering_point_id
      end
    end

    if @meter.save
      if params[:meter][:smartmeter] == I18n.t('yes')
        redirect_to edit_contract_wizard_meters_path(meter_id: @meter.id)
      else
        render action: 'update'
      end
    else
      render action: 'edit_meter', meter_id: @meter.id
    end
  end

  def edit_contract
    @meter = Meter.find(params[:meter_id])
    @contract = @meter.metering_points.first.contracts.metering_point_operators.first || Contract.new
  end

  def edit_contract_update
    @meter = Meter.find(params[:meter_id])
    @metering_point = @meter.metering_points.first
    #byebug
    if params[:contract][:id] == ""
      @contract = Contract.new(contract_params)
    else
      @contract = Contract.find(params[:contract][:id])
    end
    if !@contract.new_record?
      @contract.organization_id = params[:contract][:organization_id]
      @contract.username = params[:contract][:username]
      @contract.password = params[:contract][:password]
    end
    @contract.mode = 'metering_point_operator_contract'
    @contract.price_cents = 0
    @contract.metering_point = @metering_point
    if @contract.organization.slug == 'buzzn-metering'
      @contract.username = 'team@localpool.de'
      @contract.password = 'Zebulon_4711'
    elsif @contract.organization.slug == 'mysmartgrid'
      @contract.username = params[:contract][:sensor_id]
      @contract.password = params[:contract][:x_token]
    end

    if @contract.save && @meter.save
      if @meter.smart
        flash[:notice] = t("your_credentials_have_been_checked_and_are_valid", metering_point: @metering_point.name)
        render action: 'update'
      else
        @contract.errors.add(:password, I18n.t("wrong_username_and_or_password"))
        @contract.errors.add(:username, I18n.t("wrong_username_and_or_password"))
        @contract.destroy
        render action: 'edit_contract', meter_id: @meter.id, contract_id: ''
      end
    else
      render action: 'edit_contract', meter_id: @meter.id, contract_id: ''
    end
  end


  private

  def meter_params
    params.require(:meter).permit(:id, :metering_point_id, :manufacturer_product_serialnumber, :manufacturer_name, :metering_points)
  end

  def contract_params
    params.require(:meter).require(:contract).permit( :id, :organization_id, :username, :password)
  end

end