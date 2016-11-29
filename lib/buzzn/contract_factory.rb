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
      [:user, :profile, :other_address,
       :old_contract].each do |key|
        @params[key] ||= nil
      end
      [:address, :meter, :register, :contract, :contracting_party,
       :bank_account].each do |key|
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
          address = Address.create!(self.address)
          # TODO add to DB migration
          self.contracting_party.delete(:provider_permission)
          party_params = self.contracting_party
          if party_params[:legal_entity] == 'company'
            unless self.company
              raise Buzzn::ValidationError.new(company: 'missing company data')
            end
            orga = create(Organization,
                          self.company[:organization] || {},
                          address: address)
            party_params.merge!(self.company[:contracting_party] || {})
          end
          if self.other_address
            other = create!(:other_address, Address, self.other_address)
          end

          # TODO create both in one go
          meter = Meter.create!(self.meter)
          # TODO d osomething with this counting_point
          counting_poing = self.register.delete(:counting_point)
          register = create(Register,
                                  self.register,
                                  name: 'Wohnung',
                                  mode: 'in',
                                  meter: meter,
                                  readable: 'friends',
                                  address: other || address)

          begin
            bank = Bank.find_by_iban(self.bank_account[:iban])
          rescue Buzzn::RecordNotFound => e
            raise  Buzzn::ValidationError.new('bank_account.iban': e.message)
          end

          bank_account = build(BankAccount,
                               self.bank_account,
                               bic: bank.bic,
                               bank_name: bank.name)

          beneficiary_party = create(ContractingParty,
                                     party_params,
                                     organization: orga,
                                     address: address,
                                     bank_account: bank_account,
                                     user: @user)

          if metering_point_operator_name =  self.contract.delete(:metering_point_operator_name)
            MeteringPointOperatorContract.create!(signing_date: Time.new(0),
                                                  signing_user: @user,
                                                  terms_accepted: true,
                                                  power_of_attorney: true,
                                                  begin_date: Time.new(0),
                                                  register: register,
                                                  metering_point_operator_name: metering_point_operator_name,
                                                  contractor: Organization.dummy_energy.contracting_party,
                                                  customer: beneficiary_party)                                          
          end
          create(PowerTakerContract,
                 self.contract,
                 signing_user: @user,
                 signing_date: Time.current,                                 
                 register: register,
                 customer: beneficiary_party)
        end
      rescue ActiveRecord::RecordInvalid => e
        raise NestedValidationError.new(e)
      end
    end

    private

    def create(model, params = {}, extra = {})
      model.send(:create!, (params || {}).merge(extra))
    end

    def create!(key, model, params = {}, extra = {})
      model.send(:create!, (params || {}).merge(extra))
    rescue ActiveRecord::RecordInvalid => e
      raise NestedValidationError.new(key, e)
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
