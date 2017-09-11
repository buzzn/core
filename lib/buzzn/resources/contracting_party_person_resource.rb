require_relative 'person_resource'
class ContractingPartyPersonResource < PersonResource

  def self.new(*args)
    super
  end

  attributes  :sales_tax_number,
              :tax_rate,
              :tax_number,
              :updatable, :deletable

end
