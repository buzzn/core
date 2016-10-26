require 'buzzn/contract_factory'
module API
  module V1
    class Forms < Grape::API
      include API::V1::Defaults
      resource :forms do


        desc "Create a Power Taker with contract"
        params do
          optional :user, type: Hash do
            requires :email, type: String, desc: 'email'
            requires :password, type: String, desc: 'password'
          end
          optional :profile, type: Hash do
            optional :user_name, type: String, desc: 'username'
            requires :first_name, type: String, desc: 'first-name'
            requires :last_name, type: String, desc: 'last-name'
            optional :title, type: String, desc: 'title'
            optional :about_me, type: String, desc: 'about me'
            optional :gender, type: String, values: Profile.genders.map(&:to_s), desc: 'gender'
            optional :phone, type: String, desc: 'phone'
          end
          requires :address, type: Hash do
            requires :street_name, type: String, desc: 'street name'
            requires :street_number, type: String, desc: 'street number'
            requires :city, type: String, desc: 'city'
            requires :state, type: String, values: Address.states(&:to_s), desc: 'state'
            requires :zip, type: String, desc: 'zip'
            optional :addition, type: String, desc: 'additional info'
          end
          requires :legal_entity, type: String, values: ContractingParty.legal_entities.map(&:to_s), desc: 'legal entity'
          optional :company, type: Hash do
            requires :authorization, type: Boolean, desc: 'Authorization'
            requires :contracting_party, type: Hash do
              requires :sales_tax_number, type: Fixnum, desc: 'sales tax number'
              requires :tax_rate, type: Float, desc: 'tax rate'
              requires :tax_number, type: Fixnum, desc: 'tax number'
            end
            requires :organization, type: Hash do
              requires :name,         type: String, desc: "Name of the Organization."
              requires :email,        type: String, desc: "Email of Organization."
              optional :phone,        type: String, desc: "Phone number of Organization."
              optional :fax,          type: String, desc: "Fax number of Organization."
              optional :website,      type: String, desc: "Website of Organization."
              optional :description,  type: String, desc: "Description of the Organization."
            end
          end
          requires :meter, type: Hash do
            requires :manufacturer_product_name, desc: "meter produkt name"
            requires :manufacturer_product_serialnumber, desc: "meter produkt serialnumber"
          end
          requires :metering_point, type: Hash do
            #requires :virtual, type: Boolean, desc: 'is virtual'
            optional :uid,  type: String, desc: "UID(DE00...)"
          end
          optional :other_address, type: Hash do
            requires :street_name, type: String, desc: 'street name'
            requires :street_number, type: String, desc: 'street number'
            requires :city, type: String, desc: 'city'
            requires :state, type: String, values: Address.states(&:to_s), desc: 'state'
            requires :zip, type: String, desc: 'zip'
            optional :addition, type: String, desc: 'additional info'
          end
          optional :old_contract, type: Hash do
            requires :customer_number,          type: String,  desc: 'Customer number'
            requires :contract_number,          type: String,  desc: 'Contract number'
            
          end
          requires :contract, type: Hash do
            requires :yearly_kilo_watt_per_hour, type: Integer, desc: 'expected yearly consumption in kilo watt per hour'
            requires :tariff,               values: Buzzn::Zip2Price.types, desc: 'TODO tariff'
            optional :beginning,                 type: Date, desc: 'Begin date'
          end
          requires :bank_account, type: Hash do
            requires :holder, type: String, desc: "Holder of the Bank Account"
            requires :iban, type: String, desc: "IBAN"
          end
        end
        oauth2 false
        post 'power-taker' do
          Buzzn::ContractFactory.create_power_taker_contract(current_user, permitted_params)
          status 201
        end

      end
    end
  end
end
