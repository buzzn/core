require_relative '../localpool'

class Transactions::Admin::Localpool::SendTariffChangeLetters < Transactions::Base

  add :send_tariff_change_letters

  include Import[
    deliver_tariff_change_service: 'services.deliver_tarrif_change_letter_service',
  ]

  def send_tariff_change_letters(resource:)
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
          document = Contract::Base.find(contract.id).documents.where(purpose: 'tariff_change_letter').order(:created_at).last
          if document.nil? || document.created_at < (today - 7)
            error = Buzzn::ValidationError.new({send_tariff_change_letter: ['The tariff change letter for this contract is older than a week or not existent.']}, resource.object)
            if errors['send_tariff_change_letter'].nil?
              errors['send_tariff_change_letter'] = [{contract_id: contract.id, contract_number: contract.full_contract_number, errors: error.errors}]
            else
              errors['send_tariff_change_letter'] << {contract_id: contract.id, contract_number: contract.full_contract_number, errors: error.errors}
            end
          else
            begin
                contract_resource = resource.contracts.retrieve(contract.id)
                deliver_tariff_change_service.deliver_tariff_change_letter(resource, contract_resource, document.id)
            rescue Buzzn::ValidationError => e
              if errors['send_tariff_change_letter'].nil?
                errors['send_tariff_change_letter'] = [{contract_id: contract.id, contract_number: contract.full_contract_number, errors: e.errors}]
              else
                errors['send_tariff_change_letter'] << {contract_id: contract.id, contract_number: contract.full_contract_number, errors: e.errors}
              end
            end
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