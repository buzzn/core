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
            authorization = self.company[:authorization]
            orga = create(Organization,
                          self.company[:organization] || {},
                          address: address)
            party_params.merge!(self.company[:contracting_party] || {})
          end
          if self.other_address
            other = create!(:other_address, Address, self.other_address)
          end

          # TODO create all three in one go
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
          if self.old_contract
            # TODO contract_owner ?
            name = self.old_contract.delete(:old_electricity_supplier_name)
            old = create!(:old_contract, Contract,
                          self.old_contract,
                          #TODOorganization_name_from_form: name,
                          mode: 'electricity_supplier_contract',
                          contract_beneficiary: beneficiary_party,
                          contract_owner: Organization.dummy_energy.contracting_party)
          end

          # TODO move validation into model if possible
          if !old
            if !self.contract[:move_in]
              raise Buzzn::ValidationError.new('old_contract.old_electricity_supplier_name': 'needs an old contract if not moved in')
            elsif !self.contract[:beginning]
              raise Buzzn::ValidationError.new('contract.beginning': 'needs beginning if moved in')
            end
          else
            if self.contract[:move_in]
              raise Buzzn::ValidationError.new('old_contract.old_electricity_supplier_name': 'can not have old contract if moved in')
            elsif self.contract[:beginning]
              raise Buzzn::ValidationError.new('contract.beginning': 'can not have beginning if not moved in')
            end
          end

          owner_party = Organization.buzzn_energy.contracting_party
          #TODO each buzzn organization needs a contracting_party to start with, i.e. seeds and/or fabricator
          unless owner_party
            owner_party = build(ContractingParty,
                                {},
                                legal_entity: 'company',
                                organization: Organization.buzzn_energy)
          end

          metering_point_operator_name =  self.contract.delete(:metering_point_operator_name)
          create(Contract,
                 self.contract,
                 mode: 'power_taker_contract',
                 authorization: authorization,
                 register: register,
                 other_contract: !! old,
                 contract_beneficiary: beneficiary_party,
                 contract_owner: owner_party,
                 bank_account: bank_account)
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
