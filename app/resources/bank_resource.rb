class BankResource < ApplicationResource
  attributes  :blz,
              :bic,
              :description,
              :zip,
              :place,
              :name
end
