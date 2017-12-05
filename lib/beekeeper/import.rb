# wireup invariant with AR and raise error on invalid in before_save
require 'buzzn/schemas/support/enable_dry_validation'
require 'buzzn/types/discovergy'

ActiveRecord::Base.send(:include, Schemas::Support::ValidateInvariant)

class Beekeeper::Import
::Import['service.datasource.discsovergy.api']
  class << self
    def run!
      new.run
    end
  end

  def run
    logger.info("-" * 80)
    logger.info("Starting import")
    logger.info("-" * 80)
    import_localpools
  end

  private

  def import_localpools
    #ActiveRecord::Base.logger = Logger.new(STDOUT)
    Beekeeper::Minipool::MinipoolObjekte.to_import.each do |record|
      logger.info("\n")
      logger.info("Localpool #{record.converted_attributes[:name]} (start: #{record.converted_attributes[:start_date]})")
      logger.info("-" * 80)
      begin
        Group::Localpool.transaction do
          # need to create localpool with broken invariants
          localpool = Group::Localpool.create(record.converted_attributes.except(:registers))
          warnings  = record.warnings if record.warnings.present?
          # with localpool.id the roles on owner can be set
          add_roles(localpool)
          add_registers(localpool, record.converted_attributes[:registers])
          assign_grid_registers(localpool)
          # now we can fail and rollback on broken invariants
          unless localpool.invariant_valid?
            raise ActiveRecord::RecordInvalid.new(localpool)
          end
          # finally save it all
          localpool.save!
          warnings = add_brokers(localpool, warnings)
          log_todos(localpool.id, warnings)
        end
      #rescue => e
       # logger.error(e)
      end

    end
    log_import_summary
  end

  private

  def meter_map
    @meter_map ||=
      begin
        api = ::Import.global('service.datasource.discovergy.api')
        meters = api.request(Types::Discovergy::Meters::Get.new)
        meters.each_with_object({}) do |meter, map|
          map[meter.serialNumber] = meter if meter.type == 'EASYMETER'
        end
      end
  end

  def meter_on_discovergy?(serialnumber)
    meter_map.key?(serialnumber)
  end

  def add_brokers(localpool, warnings)
    without_broker = localpool.meters.real.select do |meter|
      if meter.easy_meter?
        if meter_on_discovergy?(meter.product_serialnumber)
          Broker::Discovergy.create!(meter: meter)
          false
        else
          # these are the ones we have, but are not on Discovergy.
          true
        end
      else
        false # non-easymeters are not smart and thus not connectable to Discovergy
      end
    end
    without_broker.each do |meter|
      meter.registers.each do |register|
        warnings ||= {}
        warnings["register '#{register.name}'"] = 'is not on Discovergy'
      end
    end
    warnings
    #without_meter = map.select { |serial, _| !Meter::Real.where(product_serialnumber: serial).exists? }
  end

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
    registers.map do |register|
      register.meter.group = localpool
      unless register.save
        logger.error("Failed to save register #{register.inspect}")
        logger.error("Errors: #{register.errors.inspect}")
      end
    end
  end

  def assign_grid_registers(localpool)
    %i(grid_consumption grid_feeding).each do |label|
      found_registers = localpool.registers.send(label)
      if found_registers.size == 1
        localpool.update_attribute("#{label}_register", found_registers.first)
      elsif found_registers.size > 1
        logger.error("Error: found more than one #{label} registers:")
        logger.error(found_registers.inspect)
      else
        # the 0/no register case is handled by the incompleteness validation below.
        # Some groups (like Orleansstraße 61 and Häberlstraße 15) use a virtual register for the grid.
        # Since we don't import those yet, those groups have incompleteness errors.
      end
    end
  end

  def logger
    @logger ||= begin
      l = Logger.new(STDOUT)
      l.formatter = proc do |_severity, _datetime, _progname, msg|
        "#{msg}\n"
      end
      l
    end
  end

  def log_todos(localpool_id, warnings)

    resource = Admin::LocalpoolResource.all(buzzn_operator_account).retrieve(localpool_id)
    incompleteness = if resource.object.start_date.future?
      logger.info("Skipping incompleteness checks, localpool hasn't started yet")
      []
    else
      resource.incompleteness
    end

    unless incompleteness.present? || warnings.present?
      logger.info("Nothing to do!")
      return
    end

    if incompleteness.present?
      incompleteness.each do |field, messages|
        logger.info("#{field}: #{messages.join(', ')} (incompleteness)")
      end
    end

    if warnings.present?
      warnings.each do |field, message|
        if message.is_a?(Hash)
          message.each do |subfield, submessage|
            logger.info("#{field}:")
            logger.info("- #{subfield}: #{submessage} (warning)")
          end
        else
          logger.info("#{field}: #{message} (warning)")
        end
      end
    end
  end

  def log_import_summary
    logger.info("\n" * 2)
    logger.info("-" * 80)
    logger.info("Import summary")
    logger.info("-" * 80)

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

  private

  def buzzn_operator_account
    @_account ||= Account::Base.find_by_email('dev+ops@buzzn.net')
  end
end
