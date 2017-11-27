# wireup invariant with AR and raise error on invalid in before_save
require 'buzzn/schemas/support/enable_dry_validation'
ActiveRecord::Base.send(:include, Buzzn::Schemas::ValidateInvariant)

class Beekeeper::Import
  class << self
    def run!
      new.run
    end
  end

  def run
    import_localpools
  end

  def import_localpools
    #ActiveRecord::Base.logger = Logger.new(STDOUT)
    Beekeeper::Minipool::MinipoolObjekte.to_import.each do |record|
      logger.debug("----")
      logger.debug("* #{record.name}")
      logger.debug(record.owner.is_a?(Person).to_s)
      logger.debug(record.owner&.bank_accounts.inspect)
      begin
        Group::Localpool.transaction do
          # need to create localpool with broken invariants
          localpool = Group::Localpool.create(record.converted_attributes)
          # with localpool.id the roles on owner can be set
          add_roles(localpool)
          # now we can fail and rollback on broken invariants
          unless localpool.invariant_valid?
            raise ActiveRecord::RecordInvalid.new(localpool)
          end
          # finally save it all
          localpool.save!
        end

      rescue => e
        ap e
        ap record.converted_attributes
      end
    end
    log_import_info
  end

  # Not used yet, created in the prototype.
  # def import_registers
  #   Beekeeper::Minipool::MsbZählwerkDaten.all.each do |record|
  #     ap({ record.register_nr => record.converted_attributes })
  #   end
  # end

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

  def logger
    @logger ||= Buzzn::Logger.new(self)
  end

  def log_import_info
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
  end
end
