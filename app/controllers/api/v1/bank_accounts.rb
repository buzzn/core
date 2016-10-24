module API
  module V1
    class BankAccounts < Grape::API
      include API::V1::Defaults
      resource 'bank-accounts' do

        desc "Return all Bank Account"
        params do
          optional :filter, type: String, desc: "Search query using #{Base.join(BankAccount.search_attributes)}"
          
          optional :per_page, type: Fixnum, desc: "Entries per Page", default: 10, max: 100
          optional :page, type: Fixnum, desc: "Page number", default: 1
        end
        paginate
        oauth2 :full
        get do
          paginated_response(BankAccount.filter(permitted_params[:filter])
                              .readable_by(current_user))
        end




        desc "Return a Bank Account"
        params do
          requires :id, type: String, desc: "ID of the Bank Account"
        end
        oauth2 :full
        get ":id" do
          BankAccount.guarded_retrieve(current_user, permitted_params)
        end





        desc "Create a Bank Account"
        params do
          requires :holder, type: String, desc: "Holder of the Bank Account"
          requires :bank_name, type: String, desc: "Bank Name"
          requires :iban, type: String, desc: "IBAN"
          requires :bic, type: String, desc: "BIC"
          requires :direct_debit, type: Boolean, desc: "Is direct debit"
          requires :bank_accountable_id, type:String, desc: 'ID of Contract or Contracting-Party'
          requires :bank_accountable_type, type:String, values:[Contract.to_s, ContractingParty.to_s], desc: 'Owner Type'
        end
        oauth2 :full
        post do
          resource = Object.const_get(permitted_params[:bank_accountable_type])
          # TODO really unguarded ?
          parent = resource.unguarded_retrieve(permitted_params[:bank_accountable_id])
          created_response(BankAccount.guarded_create(current_user,
                                                      permitted_params,
                                                      parent))
        end




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
          bank_account = BankAccount.guarded_retrieve(current_user,
                                                      permitted_params)
          bank_account.guarded_update(current_user, permitted_params)
        end




        desc "Delete a Bank Account."
        params do
          requires :id, type: String, desc: "Bank Account ID"
        end
        oauth2 :full
        delete ':id' do
          bank_account = BankAccount.guarded_retrieve(current_user,
                                                      permitted_params)
          deleted_response(bank_account.guarded_delete(current_user))
        end




      end
    end
  end
end
