class Beekeeper::Importer::Roles

  attr_reader :logger

  def initialize(logger)
    @logger = logger
    @logger.section = 'create-roles'
  end

  def run(localpool)
    owner =
      case localpool.owner
      when Organization::General
        localpool.owner.contact
      when Person
        localpool.owner
      else
        nil
      end
    if owner
      owner.add_role(Role::GROUP_OWNER, localpool)
      unless localpool.name == 'Mehrgenerationenplatz Forstenried' || (owner.first_name == 'Traudl' && owner.last_name == 'Brumbauer')
        owner.add_role(Role::GROUP_ENERGY_MENTOR, localpool)
      end
    end
  end

end
