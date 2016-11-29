class WizardRegistersController  < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js

  def wizard
    @register = Register.new
    @meter = Meter.new
    @contract = Contract.new
  end

  def wizard_update
    Register.transaction do
      @register = Register.new(register_params)
      @register.readable = 'friends'
      if @register.save!
        #byebug
        if params[:register][:add_user] == "true"
          current_user.add_role(:member, @register)
        end
        current_user.add_role(:manager, @register)

        #register is valid and now check meter
        if !@register.virtual
          if params[:register][:meter][:existing_meter] == t('add_existing_meter')
            @meter = Meter.find(params[:register][:meter][:meter_id])
          else
            @meter = Meter.new(meter_params)
          end
          @meter.registers << @register
          if @meter.registers.collect{|mp| mp.metering_point_operator_contract}.any? && params[:register][:meter][:existing_meter] == t('add_existing_meter')
            @contract = @meter.registers.collect{|mp| mp.metering_point_operator_contract}.first
            @contract2 = Contract.new
            @contract2.organization = @contract.organization
            @contract2.username = @contract.username
            @contract2.password = @contract.password
            @contract2.mode = @contract.mode
            @contract2.price_cents = @contract.price_cents
            @contract2.register = @register
            @contract2.contractor_id = @contract.contractor_id
            @contract2.save!
          end
          if @meter.save!
            if params[:register][:meter][:smartmeter] == "1" && params[:register][:meter][:existing_meter] != t('add_existing_meter')

              #meter is valid an now check contract
              @contract = Contract.new(contract_params)
              @contract.mode = 'metering_point_operator_contract'
              @contract.price_cents = 0
              @contract.register = @register
              @contract.contractor_id = current_user.contracting_parties.first.id
              if @contract.organization.slug == 'buzzn-metering' ||
                 @contract.organization.buzzn_metering?
                @contract.username = 'team@localpool.de'
                @contract.password = 'Zebulon_4711'
              elsif @contract.organization.slug == 'mysmartgrid'
                @contract.username = params[:register][:contract][:sensor_id]
                @contract.password = params[:register][:contract][:x_token]
              end
              if @contract.save! && @register.meter.save!
                if @register.smart?
                  flash[:notice] = t("your_credentials_have_been_checked_and_are_valid", register: @register.name)
                  respond_with @register
                else
                  if @contract.organization.slug == 'buzzn-metering' ||
                     @contract.organization.buzzn_metering?
                    flash[:error] = t("your_credentials_have_been_checked_and_are_invalid", register: @register.name)
                    respond_with @register
                  else
                    # @contract.errors.add(:password, I18n.t("wrong_username_and_or_password"))
                    # @contract.errors.add(:username, I18n.t("wrong_username_and_or_password"))
                    # @contract.destroy
                    # render action: 'wizard'
                    flash[:error] = t("your_credentials_have_been_checked_and_are_invalid", register: @register.name)
                    respond_with @register
                    #TODO: check via ajax
                  end
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

  def register_params
    params.require(:register).permit(
      :name,
      :mode,
      :virtual,
      formula_parts_attributes: [:id, :operator, :register_id, :operand_id, :_destroy])
  end

  def meter_params
    params.require(:register).require(:meter).permit( :manufacturer_product_serialnumber)
  end

  def contract_params
    params.require(:register).require(:contract).permit(
      :organization_id,
      :username,
      :password)
  end

end
