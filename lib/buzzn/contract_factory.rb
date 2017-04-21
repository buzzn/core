require 'buzzn'
module Buzzn

  class ContractFactory

    class << self
      def create_power_taker_contract(user, params)
        new(user, params).create_power_taker_contract
      end
    end

    def initialize(user, params)
      @user = user
      @params = params
      # setup deafults so the method_missing is working
      [:user, :profile, :other_address, :company, :old_contract, :provider_permission].each do |key|
        @params[key] ||= nil unless params.key?(key)
      end
      [:address, :meter, :register, :contract, :bank_account].each do |key|
        @params[key] ||= {}
      end
    end

    def method_missing(name, *args)
      @params.key?(name) ? @params[name] : super
    end

    def respond_to?(name)
      @params.key?(name) || super
    end

    def create_power_taker_contract
      begin
        User.transaction do
          get_or_create_user

          begin
            bank = Bank.find_by_iban(self.bank_account[:iban])
          rescue Buzzn::RecordNotFound => e
            raise  Buzzn::ValidationError.new('bank_account.iban': e.message)
          end

          bank_account = build(BankAccount,
                               self.bank_account,
                               bic: bank.bic,
                               bank_name: bank.name)

          address = Address.create!(self.address)

          customer = @user
          if self.company
            customer = create(Organization,
                              self.company[:organization] || {},
                              provider_permission: self.provider_permission,
                              address: address)
          else
            @user.update!(provider_permission: self.provider_permission,
                          address: address)
          end
          bank_account.update!(contracting_party: customer)
          if self.other_address
            other = create!(:other_address, Address, self.other_address)
          end

          # TODO do something with this counting_point
          counting_point = self.register.delete(:counting_point)
          register = build(Register::Input,
                           self.register,
                           label: Register::Base::CONSUMPTION,
                           name: 'Wohnung',
                           readable: 'friends',
                           address: other || address)
          meter = create(Meter::Real, self.meter, registers: [register])

          if metering_point_operator_name =  self.contract.delete(:metering_point_operator_name)
            Contract::MeteringPointOperator.create!(signing_date: Time.new(0),
                                                    signing_user: @user,
                                                    terms_accepted: true,
                                                    power_of_attorney: true,
                                                    begin_date: Time.new(0),
                                                    register: register,
                                                    metering_point_operator_name: metering_point_operator_name,
                                                    contractor: Organization.dummy_energy,
                                                    customer: customer)
          end
          # TODO: get real tariffs and payments
          create(Contract::PowerTaker,
                   self.contract,
                   signing_user: @user,
                   signing_date: Time.current,
                   register: register,
                   customer: customer,
                   customer_bank_account: bank_account),
                   payments: [Fabricate.build(:payment)],
                   tariffs: [Fabricate.build(:tariff)])
        end
      rescue ActiveRecord::RecordInvalid => e
        raise CascadingValidationError.new(e)
      end
    end

    private

    def create(model, params = {}, extra = {})
      model.send(:create!, (params || {}).merge(extra))
    end

    def create!(key, model, params = {}, extra = {})
      model.send(:create!, (params || {}).merge(extra))
    rescue ActiveRecord::RecordInvalid => e
      raise CascadingValidationError.new(key, e)
    end

    def build(model, params = {}, extra = {})
      model.send(:new, (params || {}).merge(extra))
    end

    def get_or_create_user
      if @user
        if self.user
          raise Buzzn::ValidationError.new(user: 'is already there')
        end
        if self.profile && @user.profile
          @user.profile.update(self.profile)
        end
      elsif self.user && !self.profile
        raise Buzzn::ValidationError.new(profile: 'is missing')
      else
        @user = User.create!(self.user)
        create(Profile, self.profile, user: @user)
      end
      # TODO move into profile
      if @user.profile.phone.nil?
        raise Buzzn::ValidationError.new('profile.phone': 'is missing')
      end
    end
  end
end
