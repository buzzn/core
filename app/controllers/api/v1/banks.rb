require 'buzzn/zip2price'
module API
  module V1
    class Banks < Grape::API
      include API::V1::Defaults

      resource :banks do

        desc 'gets the bank details for a given BIC or IBAN. note BIC is not uniq and the first entry gets returned.'
        params do
          optional :bic
          optional :iban
          exactly_one_of :bic, :iban
        end
        oauth2 false
        get do
          if bic = permitted_params[:bic]
            Bank.find_by_bic(bic)
          else
            iban = permitted_params[:iban]
            Bank.find_by_iban(iban)
          end
        end

      end
    end
  end
end
