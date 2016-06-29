class WizardMeteringPointsController  < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :js

  def wizard
    @metering_point = MeteringPoint.new
    @meter = Meter.new
    @contract = Contract.new
  end

  def wizard_update
    MeteringPoint.transaction do
      @metering_point = MeteringPoint.new(metering_point_params)
      @metering_point.readable = 'friends'
      if @metering_point.save!
        #byebug
        if params[:metering_point][:add_user] == "true"
          current_user.add_role(:member, @metering_point)
        end
        current_user.add_role(:manager, @metering_point)

        #metering_point is valid and now check meter

        if params[:metering_point][:meter][:existing_meter] == t('add_existing_meter')
          @meter = Meter.find(params[:metering_point][:meter][:meter_id])
        else
          @meter = Meter.new(meter_params)
        end
        @meter.metering_points << @metering_point
        if @meter.metering_points.collect{|mp| mp.metering_point_operator_contract}.any? && params[:metering_point][:meter][:existing_meter] == t('add_existing_meter')
          @contract = @meter.metering_points.collect{|mp| mp.metering_point_operator_contract}.first
          @contract2 = Contract.new
          @contract2.organization = @contract.organization
          @contract2.username = @contract.username
          @contract2.password = @contract.password
          @contract2.mode = @contract.mode
          @contract2.price_cents = @contract.price_cents
          @contract2.metering_point = @metering_point
          @contract2.save!
        end
        if @meter.save!
          #@metering_point.create_activity key: 'metering_point.create', owner: current_user
          if params[:metering_point][:meter][:smartmeter] == "1" && params[:metering_point][:meter][:existing_meter] != t('add_existing_meter')

            #meter is valid an now check contract
            @contract = Contract.new(contract_params)
            @contract.mode = 'metering_point_operator_contract'
            @contract.price_cents = 0
            @contract.metering_point = @metering_point
            if @contract.organization.slug == 'buzzn-metering'
              @contract.username = 'team@localpool.de'
              @contract.password = 'Zebulon_4711'
            elsif @contract.organization.slug == 'mysmartgrid'
              @contract.username = params[:metering_point][:contract][:sensor_id]
              @contract.password = params[:metering_point][:contract][:x_token]
            end
            if @contract.save! && @metering_point.meter.save!
              if @metering_point.smart?
                flash[:notice] = t("your_credentials_have_been_checked_and_are_valid", metering_point: @metering_point.name)
                render action: 'update'
              else
                if @contract.organization.slug == 'buzzn-metering'
                  flash[:error] = t("your_credentials_have_been_checked_and_are_invalid", metering_point: @metering_point.name)
                  render action: 'update'
                else
                  # @contract.errors.add(:password, I18n.t("wrong_username_and_or_password"))
                  # @contract.errors.add(:username, I18n.t("wrong_username_and_or_password"))
                  # @contract.destroy
                  # render action: 'wizard'
                  flash[:error] = t("your_credentials_have_been_checked_and_are_invalid", metering_point: @metering_point.name)
                  render action: 'update'
                  #TODO: check via ajax
                end
              end
            else
              raise ActiveRecord::Rollback
              flash[:error] = 'Error'
              render action: 'update'
            end

          else
            flash[:notice] = I18n.t('metering_point_created_successfully')
            render action: 'update'
          end
        else
          raise ActiveRecord::Rollback
          flash[:error] = 'Error'
          render action: 'update'
        end
      else
        raise ActiveRecord::Rollback
        flash[:error] = 'Error'
        render action: 'update'
      end
    end
  end


  private

  def metering_point_params
    params.require(:metering_point).permit( :name, :mode)
  end

  def meter_params
    params.require(:metering_point).require(:meter).permit( :manufacturer_product_serialnumber)
  end

  def contract_params
    params.require(:metering_point).require(:contract).permit( :organization_id, :username, :password)
  end

end