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
      [:user, :profile, :other_address, :legal_entity,
       :old_contract].each do |key|
        @params[key] ||= nil
      end
      [:address, :meter, :metering_point, :contract,
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
          user = get_or_create_user
          address = Address.create!(self.address)
          if legal_entity == 'company'
            unless self.company
              raise Buzzn::ValidationError.new(company: 'missing company data')
            end
            authorization = self.company[:authorization]
            orga = create(Organization,
                          self.company[:organization] || {},
                          address: address)
            party_params = self.company[:contracting_party]
          else
            party_params = {}
          end
          if self.other_address
            other = create!(:other_address, Address, self.other_address)
          end
          meter = Meter.create!(self.meter)

          metering_point = create(MeteringPoint,
                                  self.metering_point,
                                  name: 'Wohnung',
                                  mode: 'in',
                                  readable: 'friends',
                                  address: other || address)

          create(Register, {}, obis: '1-0:1.8.0', label: 'consumption',
                 meter: meter, metering_point: metering_point)

          bank = Bank.find_by_iban(self.bank_account[:iban])
          bank_account = build(BankAccount,
                               self.bank_account,
                               bic: bank.bic,
                               bank_name: bank.name)

          beneficiary_party = create(ContractingParty,
                                     party_params,
                                     legal_entity: legal_entity,
                                     organization: orga,
                                     address: address,
                                     bank_account: bank_account,
                                     user: user)
          if self.old_contract
            # TODO contract_owner ?
            old = create!(:old_contract, Contract,
                         self.old_contract,
                         mode: 'other',
                         contract_beneficiary: beneficiary_party,
                         contract_owner: nil)
          end

          if old && !self.contract[:beginning]
            raise Buzzn::ValidationError.new(contract: 'missing beginning on contract as there is an old contract')
          end

          owner_party = Organization.buzzn_energy.contracting_party
          #TODO each buzzn organization needs a contracting_party to start with, i.e. seeds and/or fabricator
          unless owner_party
            owner_party = build(ContractingParty,
                                {},
                                legal_entity: 'company',
                                organization: Organization.buzzn_energy)
          end

          contract = create(Contract,
                            self.contract,
                            mode: 'power_taker_contract',
                            authorization: authorization,
                            metering_point: metering_point,
                            other_contract: !! old,
                            contract_beneficiary: beneficiary_party,
                            contract_owner: owner_party,
                            bank_account: bank_account)
          # TODO this manager needs a test
          user.add_role(:manager, contract)
          contract
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
          raise Buzzn::ValidationError.new(user: 'is missing')
        end
        if self.profile && @user.profile
          raise Buzzn::ValidationError.new(profile: 'exists already for user')
        end
        @user
      else
        user = User.create!(self.user)
        create(Profile, self.profile, user: user)
        user
      end
    end
  end
end
