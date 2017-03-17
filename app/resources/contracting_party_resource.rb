class ContractingPartySerializier

  def self.new(object, *args)
    case object
    when Organization
      FullOrganizationSerializer.new(object, *args)
    when User
      FullUserSerializer.new(object, *args)
    else
      raise "can not handle type: #{object.class}"
    end
  end
end
