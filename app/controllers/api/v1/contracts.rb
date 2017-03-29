require 'buzzn/contract_factory'
require 'buzzn/zip2price'
module API
  module V1
    class Contracts < Grape::API
      include API::V1::Defaults

      resource :contracts do


        desc 'Return the related contractor for a Contract'
        params do
          requires :id, type: String, desc: 'ID of the Contract'
        end
        oauth2 :full
        get ':id/contractor' do
          Contract::BaseResource
            .retrieve(current_user, permitted_params)
            .contractor!
        end

        desc 'Return the related customer for a Contract'
        params do
          requires :id, type: String, desc: 'ID of the Contract'
        end
        oauth2 :full
        get ':id/customer' do
          Contract::BaseResource
            .retrieve(current_user, permitted_params)
            .customer!
        end


        desc 'Return all Contracts'
        params do
#          optional :filter, type: String, desc: "Search query using #{Base.join(Contract.search_attributes)}"
        end
        oauth2 :full
        get do
          Contract::BaseResource.all(current_user, permitted_params[:filter])
        end

        desc 'Return a Contract'
        params do
          requires :id, type: String, desc: 'ID of the Contract'
        end
        oauth2 :simple, :full
        get ':id' do
          Contract::BaseResource.retrieve(current_user, permitted_params)
        end






        desc 'Create Power-Taker Contract'
        params do
          optional :user, type: Hash do
            requires :email, type: String, desc: 'Email'
            requires :password, type: String, desc: 'Password'
          end
          optional :profile, type: Hash do
            optional :user_name, type: String, desc: 'Username'
            requires :first_name, type: String, desc: 'Firstname'
            requires :last_name, type: String, desc: 'Lastname'
            requires :phone, type: String, desc: 'Phone'
            optional :title, type: String, desc: 'Title'
            optional :about_me, type: String, desc: 'About me'
            optional :gender, type: String, values: Profile.genders.map(&:to_s), desc: 'gender'
          end
          requires :address, type: Hash do
            requires :street_name, type: String, desc: 'Street name'
            requires :street_number, type: String, desc: 'Street number'
            requires :city, type: String, desc: 'City'
            requires :state, type: String, values: Address.states(&:to_s), desc: 'state'
            requires :zip, type: String, desc: 'ZIP'
            optional :addition, type: String, desc: 'Additional info'
          end
          requires :contracting_party, type: Hash do
            requires :legal_entity, type: String, values: ['company', 'natural_person'], desc: 'legal entity'
            optional :provider_permission, type: Boolean, desc: 'Provider permission'
          end
          optional :company, type: Hash do
            requires :contracting_party, type: Hash do
              requires :sales_tax_number, type: Fixnum, desc: 'Sales tax number'
              requires :tax_rate, type: Float, desc: 'Tax rate'
              requires :tax_number, type: Fixnum, desc: 'Tax number'
            end
            requires :organization, type: Hash do
              requires :name,         type: String, desc: "Name of the Organization."
              requires :email,        type: String, desc: "Email of Organization."
              requires :represented_by, type: String, desc: 'Represented by'
              requires :retailer, type: Boolean, desc: 'Is retailer'
              optional :phone,        type: String, desc: "Phone number of Organization."
              optional :fax,          type: String, desc: "Fax number of Organization."
              optional :website,      type: String, desc: "Website of Organization."
              optional :description,  type: String, desc: "Description of the Organization."
            end
          end
          requires :meter, type: Hash do
            requires :metering_type, values: Buzzn::Zip2Price.types, desc: 'Meter-type'
            requires :manufacturer_name, desc: "Meter name", values: Meter::Real.manufacturer_names
            requires :manufacturer_product_name, desc: "Meter product name"
            requires :manufacturer_product_serialnumber, desc: "Meter product serialnumber"
          end
          optional :register, type: Hash do
            optional :counting_point, type: String, desc: 'Counting Point'
            optional :uid,  type: String, desc: "UID(DE00...)"
          end
          optional :other_address, type: Hash do
            requires :street_name, type: String, desc: 'Street name'
            requires :street_number, type: String, desc: 'Street number'
            requires :city, type: String, desc: 'City'
            requires :state, type: String, values: Address.states(&:to_s), desc: 'state'
            requires :zip, type: String, desc: 'ZIP'
            optional :addition, type: String, desc: 'Additional info'
          end
          optional :old_contract, type: Hash do
            requires :old_electricity_supplier_name, type: String, desc: 'Name of old contract'
            optional :customer_number,          type: String,  desc: 'Customer number'
            optional :contract_number,          type: String,  desc: 'Contract number'

          end
          requires :contract, type: Hash do
            optional :old_supplier_name, type: String, desc: 'Name of old contract'
            optional :old_customer_number,          type: String,  desc: 'Customer number'
            optional :old_account_number,          type: String,  desc: 'Contract number'
            requires :forecast_kwh_pa, type: Integer, desc: 'Expected yearly consumption in kilowatt-hours'
            requires :power_of_attorney, type: Boolean, desc: 'Give power of attorney'
            requires :terms_accepted, type: Boolean, desc: 'Aggree to terms'
            optional :metering_point_operator_name, type: String, desc: 'Name of Meteringpoint-Operator'
            optional :message_to_buzzn, type: String, desc: 'A message to buzzn'
            optional :hear_about_buzzn, type: String, desc: 'Hear about buzzn'
            optional :begin_date, type: Date, desc: 'Begin date'
          end
          requires :bank_account, type: Hash do
            requires :holder, type: String, desc: "Holder of the Bank Account"
            requires :iban, type: String, desc: "IBAN"
            requires :direct_debit, type: Boolean, desc: 'Allow buzzn to make a direct debit'
          end
        end
        oauth2 false
        post 'power-taker' do
          Buzzn::ContractFactory.create_power_taker_contract(current_user, permitted_params)
          status 201
        end


        desc 'Update a Contract'
        params do
          requires :id,                       type: String, desc: 'Contract ID'
          optional :mode,                     type: String, desc: 'Contract description'
          optional :organization_id,          type: String, desc: 'Organization id'
          optional :tariff,                   type: String, desc: 'Tariff'
          optional :status,                   type: String, desc: 'Status'
          optional :customer_number,          type: String, desc: 'Customer number'
          optional :contract_number,          type: String, desc: 'Contract number'
          optional :signing_user,             type: String, desc: 'Signing user'
          optional :terms,                    type: Boolean, desc: 'Terms'
          optional :power_of_attorney,        type: Boolean, desc: 'Power of attorney'
          optional :confirm_pricing_model,    type: Boolean, desc: 'Confirm pricing model'
          optional :commissioning,            type: Date, desc: 'Commissioning'
          optional :retailer,                 type: Boolean, desc: 'Is a Retailer'
          optional :price_cents_per_kwh,      type: Float, desc: 'Price per KWH incents'
          optional :price_cents_per_month,    type: Integer, desc: 'Price per month in cents'
          optional :discount_cents_per_month, type: Integer, desc: 'Discount per month in cents'
          optional :other_contract,           type: Boolean, desc: 'Has other contract'
          optional :move_in,                  type: Boolean, desc: 'Move in'
          optional :beginning,                type: Date, desc: 'Begin date'
          optional :authorization,            type: Boolean, desc: 'Authorization'
          optional :feedback,                 type: String, desc: 'Feedback'
          optional :attention_by,             type: String, desc: 'Attention by'
          optional :username,                 type: String, desc: 'Username'
          optional :password,                 type: String, desc: 'Password'
          optional :contractor_id,      type: String,  desc: 'ContractingParty Owner ID'
          optional :customer_id,type: String,  desc: 'ContractingParty Beneficiary ID'
        end
        oauth2 :full
        patch ':id' do
          Contract::BaseResource
            .retrieve(current_user, permitted_params)
            .update(permitted_params)
        end


        desc 'Delete a Contract'
        params do
          requires :id, type: String, desc: 'Contract ID'
        end
        oauth2 :full
        delete ':id' do
           deleted_response(Contract::BaseResource
                             .retrieve(current_user, permitted_params)
                             .delete)
        end


      end
    end
  end
end
