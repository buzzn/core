OrganizationIncompleteness = Dry::Validation.Schema do
  required(:contact).filled
end
