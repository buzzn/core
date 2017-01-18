class BankResource < JSONAPI::Resource
  attributes  :blz,
              :bic,
              :description,
              :zip,
              :place,
              :name
end
