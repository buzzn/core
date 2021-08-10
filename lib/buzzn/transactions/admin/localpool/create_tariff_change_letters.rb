require 'zip'
require_relative '../localpool'

class Transactions::Admin::Localpool::CreateTariffChangeLetters < Transactions::Base

  add :create_tariff_change_letters
  map :wrap_up


  def create_tariff_change_letters(resource:)
    zio = StringIO.new('')
    buffer = ::Zip::OutputStream.write_buffer(zio) do |zos|
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
            contract_resource = resource.contracts.retrieve(contract.id)
            Transactions::Admin::Contract::Document.new.(resource: contract_resource,
                                                        params: params)
            document = Contract::Base.find(contract.id).documents.where(purpose: 'tariff_change_letter').order(:created_at).last
            unless document.nil?
              zos.put_next_entry(document.filename, nil, ::Zip::Entry::STORED)
              zos << document.read
            end
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
    buffer
  end

  def wrap_up(create_tariff_change_letters:, **)
    create_tariff_change_letters
  end

end
