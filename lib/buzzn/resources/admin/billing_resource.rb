require_relative 'billing_item_resource'
require_relative '../accounting/entry_resource'

module Admin
  class BillingResource < Buzzn::Resource::Entity

    model Billing

    attributes :begin_date,
               :end_date,
               :last_date,
               :invoice_number,
               :invoice_number_addition,
               :full_invoice_number,
               :allowed_actions,
               :status

    has_one :contract
    has_many :items, BillingItemResource
    has_one :accounting_entry, Accounting::EntryResource
    has_many :documents

    def allowed_actions
      allowed = {}
      if allowed?(permissions.update)
        allowed[:update] = {}
        allowed[:update][:status] = {}
        object.allowed_transitions.each do |transition|
          allowed[:update][:status][transition] = if status.to_sym == :calculated && transition == :documented
                                                    change_from_calculated_to_documented.success? || change_from_calculated_to_documented.errors
                                                  elsif status.to_sym == :documented && transition == :documented
                                                    change_from_documented_to_documented.success? || change_from_documented_to_documented.errors
                                                  elsif status.to_sym == :documented && transition == :queued
                                                    change_from_documented_to_queued.success? || change_from_documented_to_queued.errors
                                                  else
                                                    true
                                                  end
        end
      end
      allowed
    end

    def change_from_calculated_to_documented
      subject = Schemas::Support::ActiveRecordValidator.new(self.object)
      Schemas::PreConditions::Billing::Update::CalculatedDocumented.call(subject)
    end

    def change_from_documented_to_documented
      subject = Schemas::Support::ActiveRecordValidator.new(self.object)
      Schemas::PreConditions::Billing::Update::DocumentedDocumented.call(subject)
    end

    def change_from_documented_to_queued
      subject = Schemas::Support::ActiveRecordValidator.new(self.object)
      Schemas::PreConditions::Billing::Update::DocumentedQueued.call(subject)
    end

  end
end
