require_relative '../localpool'

class Transactions::Admin::Localpool::CreateTariffChangeLetters < Transactions::Base

  #check :authorize, with: :'operations.authorization.document'
  tee :create_tariff_change_letters


  def create_tariff_change_letters(resource:)
    register_metas = resource.object.register_metas_by_registers.uniq # uniq is critically important here!
    errors = {}
    today = Date.today
    if resource.object.tariffs.any? {|tariff| tariff.begin_date >= today }
        register_metas.
        flat_map(&:contracts). # Take all groups contracts
        reject{|c| c.is_a?(Contract::LocalpoolThirdParty)}. # No Third party contracts
        select{|contract| contract.tariffs.any? {|tariff| tariff.begin_date >= today }}.each do |contract| #  Select all contracts with upcoming tariff
            if ((!contract.active?) && !contract.is_a?(Contract::LocalpoolGap))
                next
            end
            begin
            params = {}
            params['template'] = "tariff_change_letter"
            Transactions::Admin::Contract::Document.new.(resource: contract,
                                                        params: params)
            rescue Buzzn::ValidationError => e
            errors['create_tariff_change_letter'] << {contract_id: contract.id, contract_number: contract.full_contract_number, errors: e.errors}
            end
        end
    else
        raise Buzzn::ValidationError.new({create_tariff_change_letter: ['There is no upcoming tariff present in the group which can be communicated to the powertakers.']}, resource.object)
    end
    unless errors.empty?
      raise Buzzn::ValidationError.new(errors, resource.object)
    end
  end

end
