module API
  module V1
    class BankAccounts < Grape::API
      include API::V1::Defaults
      resource 'bank-accounts' do


        desc "Update a Bank Account."
        params do
          requires :id, type: String, desc: "Bank Account ID"
          optional :holder, type: String, desc: "Holder of the Bank Account"
          optional :bank_name, type: String, desc: "Bank Name"
          optional :iban, type: String, desc: "IBAN"
          optional :bic, type: String, desc: "BIC"
          optional :direct_debit, type: Boolean, desc: "Is direct debit"
        end
        oauth2 :full
        patch ':id' do
          BankAccountResource
            .retrieve(current_user, permitted_params)
            .update(permitted_params)
        end
      end
    end
  end
end
