require 'active_support/concern'

class Beekeeper::Minipool::MinipoolObjekte < Beekeeper::Minipool::BaseRecord
  module Owner

    extend ActiveSupport::Concern


    def owner
      owner = if account_new.privat1_gbr2_weg3_else4 == 'privat'
        owner_person
      else
        owner_organization
      end
      owner.customer_number = CustomerNumber.find_or_create_by!(id: vertragskontonummer)
      owner
    end

    private

    def owner_person
      Person.new(kontakt_acc.converted_attributes.merge(bank_accounts: bank_accounts))
    end

    def owner_organization
      attributes = account_new.converted_attributes(bank_accounts)
      slug = Buzzn::Slug.new(attributes[:name])
      Organization.find_by(slug: slug) || Organization.new(attributes.merge(contact: orga_contact))
    end

    def orga_contact
      Person.new(kontakt_acc.converted_attributes)
    end

    def account_new
      Beekeeper::Buzzn::AccountNew.find(vertragskontonummer)
    end

    def kontakt_acc
      Beekeeper::Buzzn::KontaktAcc.find(vertragskontonummer)
    end

    def bank_accounts
      konto = Beekeeper::Minipool::Kontodaten.where(vertragsnummer: vertragsnummer, nummernzusatz: 0).first
      [BankAccount.new(konto.converted_attributes)]
    rescue Buzzn::RecordNotFound => e
      logger.warn("#{name}: unable to find bank data: #{e.message}}")
      []
    end
  end
end
