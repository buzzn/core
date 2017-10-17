require_relative 'support/form'
ContractTaxDataContraints = Buzzn::Schemas.Form do
  optional(:retailer).filled(:bool?)
  optional(:provider_permission).filled(:bool?)
  optional(:subject_to_tax).filled(:bool?)
  optional(:tax_rate).filled(:int?, gteq?: 0, lteq?: 100)
  optional(:tax_number).filled(:str?, max_size?: 64)
  optional(:sales_tax_number).filled(:str?, max_size?: 64)
  optional(:creditor_identification).filled(:str?, max_size?: 64)
end
