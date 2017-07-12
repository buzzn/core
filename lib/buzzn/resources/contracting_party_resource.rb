class ContractingPartyResource

  def self.new(object, *args)
    case object
    when Organization
      ContractingPartyOrganizationResource.new(object, *args)
    when Person
      ContractingPartyPersonResource.new(object, *args)
    else
      raise "can not handle type: #{object.class}"
    end
  end
end
