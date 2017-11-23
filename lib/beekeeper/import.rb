# wireup invariant with AR validation
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
    Beekeeper::Minipool::MinipoolObjekte.to_import.each do |record|
      logger.info("----")
      logger.info("* #{record.name}")
      logger.info(record.owner.is_a?(Person).to_s)
      logger.info(record.owner&.bank_accounts.inspect)
      begin
        Group::Localpool.create!(record.converted_attributes)
      rescue => e
        ap e
        ap record.converted_attributes
      end
    end
    logger.info("groups                               : #{Group::Localpool.count}")
    logger.info("groups distribution_system_operator  : #{Group::Localpool.where('distribution_system_operator_id IS NOT NULL').count}")
    logger.info("groups transmission_system_operator  : #{Group::Localpool.where('transmission_system_operator_id IS NOT NULL').count}")
    logger.info("groups electricity_supplier          : #{Group::Localpool.where('electricity_supplier_id IS NOT NULL').count}")
    logger.info("group person owners                  : #{Group::Localpool.where('owner_person_id IS NOT NULL').count}")
    logger.info("group person owner addresses         : #{Group::Localpool.where('owner_person_id IS NOT NULL').select {|g| g.owner.address }.count}")
    logger.info("group person owner with bank-accounts: #{Group::Localpool.where('owner_person_id IS NOT NULL').select {|g| !g.owner.bank_accounts.empty? }.count}")

   # binding.pry
  end

  # Not used yet, created in the prototype.
  # def import_registers
  #   Beekeeper::MsbZählwerkDaten.all.each do |record|
  #     ap({ record.register_nr => record.converted_attributes })
  #   end
  # end

  private

  def logger
    @logger ||= Buzzn::Logger.new(self)
  end
end
