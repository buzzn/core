class Beekeeper::Importer::LogImportSummary

  attr_reader :logger

  def initialize(logger)
    @logger = logger
  end

  def run
    logger.info("\n" * 2)
    logger.info('-' * 80)
    logger.info('Import summary')
    logger.info('-' * 80)

    logger.info("localpools                                               : #{Group::Localpool.count}")
    logger.info("organizations                                            : #{Organization.count}")
    logger.info("persons                                                  : #{Person.count}")
    logger.info("contracts                                                : #{Contract::Base.count}")
    logger.info("registers                                                : #{Register::Real.count}")
    logger.info("readings                                                 : #{Reading::Single.count}")
    logger.info("meters                                                   : #{Meter::Real.count}")
    logger.info("billings                                                 : #{Billing.count}")

    logger.info('-' * 80)
    logger.info('Localpool contracts')
    logger.info('-' * 80)
    logger.info("regular powertakers                                      : #{Contract::LocalpoolPowerTaker.count}")
    logger.info("third-party                                              : #{Contract::LocalpoolThirdParty.count}")
    logger.info("gap                                                      : #{Contract::LocalpoolGap.count}")
    logger.info("powertaker with person customer                          : #{Contract::LocalpoolPowerTaker.where('customer_person_id is not null').count}")
    logger.info("powertaker with organization customer                    : #{Contract::LocalpoolPowerTaker.where('customer_organization_id is not null').count}")
    logger.info("groups distribution_system_operator                      : #{Group::Localpool.where('distribution_system_operator_id IS NOT NULL').count}")

    logger.info('-' * 80)
    logger.info('Other')
    logger.info('-' * 80)
    logger.info("groups transmission_system_operator                      : #{Group::Localpool.where('transmission_system_operator_id IS NOT NULL').count}")
    logger.info("groups electricity_supplier                              : #{Group::Localpool.where('electricity_supplier_id IS NOT NULL').count}")
    logger.info("group person owners                                      : #{Group::Localpool.where('owner_person_id IS NOT NULL').count}")
    logger.info("group person owner addresses                             : #{Group::Localpool.where('owner_person_id IS NOT NULL').select {|g| g.owner.address }.count}")
    logger.info("group person owner with bank-accounts                    : #{Group::Localpool.where('owner_person_id IS NOT NULL').select {|g| !g.owner.bank_accounts.empty? }.count}")
    logger.info("group orga owners                                        : #{Group::Localpool.where('owner_organization_id IS NOT NULL').count}")
    logger.info("group orga owner addresses                               : #{Group::Localpool.where('owner_organization_id IS NOT NULL').select {|g| g.owner.address }.count}")
    logger.info("group orga owner with bank-accounts                      : #{Group::Localpool.where('owner_organization_id IS NOT NULL').select {|g| !g.owner.bank_accounts.empty? }.count}")
    logger.info("group orga contacts                                      : #{Group::Localpool.where('owner_organization_id IS NOT NULL').select {|g| g.owner.contact_id }.count}")
    logger.info("group orga contact addresses                             : #{Organization.where(id: Group::Localpool.where('owner_organization_id IS NOT NULL').select(:owner_organization_id)).joins(:contact).where('persons.address_id IS NOT NULL').count}")
    powertakers = Person.where(id: Contract::LocalpoolPowerTaker.all.select(:customer_person_id))
    logger.info("localpool powertaker person                              : #{powertakers.count}")
    logger.info("localpool powertaker person with address                 : #{powertakers.where("address_id is not null").count}")
    powertakers = Organization.where(id: Contract::LocalpoolPowerTaker.all.select(:customer_organization_id))
    logger.info("localpool powertaker organization                        : #{powertakers.count}")
    logger.info("localpool powertaker organization with address           : #{powertakers.where("address_id is not null").count}")
  end

end
