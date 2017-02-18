require 'buzzn/contract_factory'
module API
  module V1
    class Forms < Grape::API
      include API::V1::Defaults
      resource :forms do


        desc "Create a Power Taker with contract"
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
            requires :authorization, type: Boolean, desc: 'Authorization'
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
            optional :manufacturer_name, desc: "Meter name", default: 'other'
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
            requires :yearly_kilowatt_hour, type: Integer, desc: 'Expected yearly consumption in kilowatt-hours'
            requires :power_of_attorney, type: Boolean, desc: 'Give power of attorney'
            requires :terms, type: Boolean, desc: 'Aggree to terms'
            requires :move_in, type: Boolean, desc: 'Whether to move in'
            optional :other_contract, type: Boolean, desc: 'There is already a power-taker contract with buzzn'
            optional :metering_point_operator_name, type: String, desc: 'Name of Meteringpoint-Operator'
            optional :message_to_buzzn, type: String, desc: 'A message to buzzn'
            optional :hear_about_buzzn, type: String, desc: 'Hear about buzzn'
            optional :beginning, type: Date, desc: 'Begin date'
          end
          requires :bank_account, type: Hash do
            requires :holder, type: String, desc: "Holder of the Bank Account"
            requires :iban, type: String, desc: "IBAN"
            requires :direct_debit, type: Boolean, desc: 'Allow buzzn to make a direct debit'
          end
        end
        oauth2 false
        post 'power-taker' do
          contract = permitted_params[:contract]
          contract[:begin_date] = permitted_params[:contract].delete(:beginning)
          contract[:terms_accepted] = permitted_params[:contract].delete(:terms)
          contract[:forecast_kwh_pa] = permitted_params[:contract].delete(:yearly_kilowatt_hour)
          contract.delete(:move_in)
          contract.delete(:other_contract)
          if old = permitted_params.delete(:old_contract)
            contract[:old_supplier_name] = old[:old_electricity_supplier_name]
            contract[:old_customer_number] = old[:customer_number]
            contract[:old_account_number] = old[:contract_number]
          end
          if company = permitted_params[:company]
            company.delete(:authorization)
          end

          Buzzn::ContractFactory.create_power_taker_contract(current_user, permitted_params)
          status 201
        end

      end
    end
  end
end
