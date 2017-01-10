class WizardRegistersController  < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js

  def wizard
    @register = Register::Base.new
    @real_register = Register::Real.new
    @virtual_register = Register::Virtual.new
    @real_meter = Meter::Real.new
    @virtual_meter = Meter::Virtual.new
    @broker = Broker.new
  end

  def wizard_update
    #byebug
    Register::Base.transaction do
      if register_base_params[:virtual] == "1"
        @register = Register::Virtual.new(register_virtual_params)
      else # not virtual
        if register_base_params[:mode] == "in"
          @register = Register::Input.new(register_base_params)
        else
          @register = Register::Output.new(register_base_params)
        end
      end
      @register.readable = 'friends'

      if params[:register_base][:add_user] == "true"
        current_user.add_role(:member, @register)
      end
      current_user.add_role(:manager, @register)

      #register is OK, now check meter
      if register_base_params[:virtual] == "1"
        @meter = Meter::Virtual.new(meter_params)
        @meter.register = @register
        @register.meter = @meter

        @register.formula_parts.clear
        @formula_parts = []
        register_virtual_params[:formula_parts_attributes].each do |key, value|
          @formula_parts << Register::FormulaPart.new(operator: value[:operator], operand_id: value[:operand_id])
          #@register.formula_parts << @formula_part
        end

      else # not virtual
        if params[:register_base][meter_class][:existing_meter] == t('add_existing_meter')
          @meter = Meter::Base.find(params[:register_base][meter_class][:meter_id])
        else
          @meter = Meter::Real.new(meter_params)
          @meter.manufacturer_name = "easy_meter"
          @meter.manufacturer_product_name = "Q3D"
        end
        @register.meter = @meter
        @meter.registers << @register

        #meter is OK, now check credentials
        if params[:register_base][meter_class][:smartmeter] == "1" && params[:register_base][meter_class][:existing_meter] == t('create_new_meter')
          organization = Organization.find(credential_params[:organization])
          if organization.slug == 'buzzn-metering' || organization.buzzn_systems? || organization.slug == 'discovergy'
            @broker = DiscovergyBroker.new(
              mode: register_base_params[:mode],
              external_id: "EASYMETER_#{@meter.manufacturer_product_serialnumber}",
              provider_login: (organization.slug == 'buzzn-metering' || organization.buzzn_systems?) ? 'team@localpool.de' : credential_params[:provider_login],
              provider_password: (organization.slug == 'buzzn-metering' || organization.buzzn_systems?) ? 'Zebulon_4711' : credential_params[:provider_password],
            )
          else
            @broker = MySmartGridBroker.new(
              mode: register_base_params[:mode],
              provider_login: credential_params[:sensor_id],
              provider_password: credential_params[:x_token],
            )
          end
        end
      end
      if @register.save && @meter.save
        if @formula_parts
          @formula_parts.each do |formula_part|
            formula_part.register = @register
            if !formula_part.save
              raise ActiveRecord::Rollback
              flash[:error] = 'Error'
              render action: 'reload'
            end
          end
        end
      else
        raise ActiveRecord::Rollback
        flash[:error] = 'Error'
        render action: 'reload'
      end
    end

    byebug


    if @broker
      @broker.resource = @meter
      if @broker.save
        if @meter.smart
          flash[:notice] = t("your_credentials_have_been_checked_and_are_valid", register: @register.name)
          respond_with @register
        else
          flash[:error] = t("your_credentials_have_been_checked_and_are_invalid", register: @register.name)
          respond_with @register
        end
      else
        flash[:error] = t("your_credentials_have_been_checked_and_are_invalid", register: @register.name)
        respond_with @register
      end
    else
      flash[:notice] = t("register_created_successfully")
      respond_with @register
    end


  end


  private

  def meter_class
    if register_base_params[:virtual] != "1"
      :meter_real
    elsif register_base_params[:virtual] == "1"
      :meter_virtual
    end
  end


  def register_base_params
    params.require(:register_base).permit(
      :name,
      :mode,
      :virtual)
  end

  def register_virtual_params
    params.require(:register_base).require(:register_virtual).permit(
      formula_parts_attributes: [:operator, :operand_id, :_destroy]
    ).merge(register_base_params)
  end

  def meter_params
    params.require(:register_base).require(meter_class).permit( :manufacturer_product_serialnumber)
  end

  def credential_params
    params.require(:register_base).require(:broker).permit(
      :organization,
      :provider_login,
      :provider_password,
      :sensor_id,
      :x_token)
  end


end
