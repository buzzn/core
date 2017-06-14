class BankSerializer < Buzzn::Resource::Base
  attributes  :blz,
              :bic,
              :description,
              :zip,
              :place,
              :name
end
