class WizardRegistersController  < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js

  def wizard
    @register = Register::Base.new
    @meter = Meter::Base.new
    @broker = Broker.new
  end

  def wizard_update
    Register::Base.transaction do
      if register_params[:mode] == "in"
        @register = Register::Input.new(register_params)
      else
        @register = Register::Output.new(register_params)
      end

      @register.readable = 'friends'
      if @register.save!
        #byebug
        if params[:register_base][:add_user] == "true"
          current_user.add_role(:member, @register)
        end
        current_user.add_role(:manager, @register)

        #register is valid and now check meter
        if !@register.virtual
          if params[:register_base][:meter][:existing_meter] == t('add_existing_meter')
            @meter = Meter::Base.find(params[:register_base][:meter][:meter_id])
          else
            @meter = Meter::Real.new(meter_params)
          end
          @meter.registers << @register

          if @meter.save!
            if params[:register_base][:meter][:smartmeter] == "1" && params[:register_base][:meter][:existing_meter] != t('add_existing_meter')

              #meter is valid an now check contract

              organization = Organization.find(credential_params[:organization])
              if organization.slug == 'buzzn-metering' || organization.buzzn_systems? || organization.slug == 'discovergy'
                @broker = DiscovergyBroker.new(
                  mode: register_params[:mode],
                  external_id: "EASYMETER_#{meter_params[:manufacturer_product_serialnumber]}",
                  provider_login: (organization.slug == 'buzzn-metering' || organization.buzzn_systems?) ? 'team@localpool.de' : credential_params[:provider_login],
                  provider_password: (organization.slug == 'buzzn-metering' || organization.buzzn_systems?) ? 'Zebulon_4711' : credential_params[:provider_password],
                  resource: @meter
                )
              else
                @broker = MySmartGridBroker.new(
                  mode: register_params[:mode],
                  provider_login: credential_params[:sensor_id],
                  provider_password: credential_params[:x_token],
                  resource: @meter
                )
              end
              if @broker.save! && @meter.save!
                if @register.smart?
                  flash[:notice] = t("your_credentials_have_been_checked_and_are_valid", register: @register.name)
                  respond_with @register
                else
                  flash[:error] = t("your_credentials_have_been_checked_and_are_invalid", register: @register.name)
                  respond_with @register
                end
              else
                raise ActiveRecord::Rollback
                flash[:error] = 'Error'
                render action: 'reload'
              end

            else #@register.smart == false
              flash[:notice] = I18n.t('register_created_successfully')
              respond_with @register
            end
          else
            raise ActiveRecord::Rollback
            flash[:error] = 'Error'
            render action: 'reload'
          end
        else #@register.virtual == true
          flash[:notice] = I18n.t('register_created_successfully')
          respond_with @register
        end
      else
        raise ActiveRecord::Rollback
        flash[:error] = 'Error'
        render action: 'reload'
      end
    end
  end


  private

  def set_contract_default_values(contract)
    contract.signing_date = Time.current
    contract.terms_accepted = true
    contract.power_of_attorney = true
    contract.begin_date = Time.current
    contract.metering_point_operator_name = "nothing"
  end

  def register_params
    params.require(:register_base).permit(
      :name,
      :mode,
      :virtual,
      formula_parts_attributes: [:id, :operator, :register_id, :operand_id, :_destroy])
  end

  def meter_params
    params.require(:register_base).require(:meter).permit( :manufacturer_product_serialnumber)
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
