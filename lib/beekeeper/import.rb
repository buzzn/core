# wireup invariant with AR and raise error on invalid in before_save
require 'buzzn/schemas/support/enable_dry_validation'
ActiveRecord::Base.send(:include, Schemas::Support::ValidateInvariant)

class Beekeeper::Import
  class << self
    def run!
      new.run
    end
  end

  def run
    import_localpools
  end

  private

  def import_localpools
    #ActiveRecord::Base.logger = Logger.new(STDOUT)
    Beekeeper::Minipool::MinipoolObjekte.to_import.all.each do |record|
      logger.debug("----")
      logger.debug("* #{record.name}")
      logger.debug(record.owner.is_a?(Person).to_s)
      logger.debug(record.owner&.bank_accounts.inspect)
      begin
        Group::Localpool.transaction do
          # need to create localpool with broken invariants
          localpool = Group::Localpool.create(record.converted_attributes.except(:registers))
          # with localpool.id the roles on owner can be set
          add_roles(localpool)
          add_registers(localpool, record.converted_attributes[:registers])
          # now we can fail and rollback on broken invariants
          unless localpool.invariant_valid?
            raise ActiveRecord::RecordInvalid.new(localpool)
          end
          # finally save it all
          localpool.save!
        end

      rescue => e
        logger.error(e)
      end
    end
    log_import_info
    log_localpool_completeness
  end

  private

  def add_roles(localpool)
    owner =
      case localpool.owner
      when Organization
        localpool.owner.contact
      when Person
        localpool.owner
      else
        nil
      end
    if owner
      owner.add_role(Role::GROUP_OWNER, localpool)
    end
  end

  def add_registers(localpool, registers)
    registers.each do |register|
      register.group_id = localpool.id
      register.meter.group_id = localpool.id
      unless register.save
        logger.error("Failed to save register #{register.inspect}")
        logger.error("Errors: #{register.errors.inspect}")
      end
    end
  end

  def logger
    @logger ||= Buzzn::Logger.new(self)
  end

  def log_import_info
    logger.info('')
    logger.info("groups                               : #{Group::Localpool.count}")
    logger.info("groups distribution_system_operator  : #{Group::Localpool.where('distribution_system_operator_id IS NOT NULL').count}")
    logger.info("groups transmission_system_operator  : #{Group::Localpool.where('transmission_system_operator_id IS NOT NULL').count}")
    logger.info("groups electricity_supplier          : #{Group::Localpool.where('electricity_supplier_id IS NOT NULL').count}")
    logger.info("group person owners                  : #{Group::Localpool.where('owner_person_id IS NOT NULL').count}")
    logger.info("group person owner addresses         : #{Group::Localpool.where('owner_person_id IS NOT NULL').select {|g| g.owner.address }.count}")
    logger.info("group person owner with bank-accounts: #{Group::Localpool.where('owner_person_id IS NOT NULL').select {|g| !g.owner.bank_accounts.empty? }.count}")
    logger.info("group orga owners                    : #{Group::Localpool.where('owner_organization_id IS NOT NULL').count}")
    logger.info("group orga owner addresses           : #{Group::Localpool.where('owner_organization_id IS NOT NULL').select {|g| g.owner.address }.count}")
    logger.info("group orga owner with bank-accounts  : #{Group::Localpool.where('owner_organization_id IS NOT NULL').select {|g| !g.owner.bank_accounts.empty? }.count}")
    logger.info("group orga contacts                  : #{Group::Localpool.where('owner_organization_id IS NOT NULL').select {|g| g.owner.contact_id }.count}")
    logger.info("group orga contact addresses         : #{Organization.where(id: Group::Localpool.where('owner_organization_id IS NOT NULL').select(:owner_organization_id)).joins(:contact).where('persons.address_id IS NOT NULL').count}")
    logger.info("registers                            : #{Register::Real.count}")
    logger.info("meters                               : #{Meter::Real.count}")
  end

  def log_localpool_completeness
    logger.info('')
    admin = Account::Base.find_by_email('dev+ops@buzzn.net')
    Admin::LocalpoolResource.all(admin).each do |localpool|
      incompleteness = localpool.incompleteness.select {|k,v| k != :grid_feeding_register && k != :grid_consumption_register }
      unless incompleteness.empty?
        logger.info("localpool #{localpool.slug}:\n\t#{incompleteness.collect { |k, v| "#{k}: #{v}" }.join "\n\t"}")
      end
    end
  end
end
