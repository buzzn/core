module Contract
  class LocalpoolProcessingResource < BaseResource

    model LocalpoolProcessing

    attributes :first_master_uid,
               :second_master_uid,
               :begin_date,
               :subject_to_tax,
               :sales_tax_number,
               :tax_number,
               :tax_rate,
               :creditor_idenfication,
               :retailer,
               :provider_permission

  end
end
