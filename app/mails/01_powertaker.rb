require_relative 'generator'

module Mail
  class PowerTaker < Generator

    attr_reader :form_content

    def initialize(form_content)
      super
      @form_content = form_content
    end

    protected

    def delivery_date
      Date.parse(form_content&.[](:oldSupplier)&.[](:deliveryStart))
    rescue ArgumentError, TypeError
      nil
    end

    def capitalize(val)
      if val.class == String
        val.capitalize
      else
        val
      end
    end

    def build_struct
      {
        :customer => build_customer,
        :calculator    => {
          :type          => form_content&.[](:calculator)&.[](:type) || 'single',
          :zip           => build_zip,
          :annual_kwh    => form_content&.[](:calculator)&.[](:annual_kwh),
          :customer_type => form_content&.[](:calculator)&.[](:customerType) || 'person',
          :group         => (form_content&.[](:calculator)&.[](:group) || 'none').titleize
        },
        :personal_info => build_personal_info,
        :address       => build_address,
        :old_supplier  => {
          :type                     => form_content&.[](:oldSupplier)&.[](:type),
          :previous_provider        => form_content&.[](:oldSupplier)&.[](:previousProvider),
          :previous_customer_number => form_content&.[](:oldSupplier)&.[](:previousCustomerNumber),
          :meter_number             => form_content&.[](:oldSupplier)&.[](:meterNumber),
          :meter_reading            => form_content&.[](:oldSupplier)&.[](:meterReading),
          :delivery_start           => delivery_date,
        },
        :bank          => {
          :account_name   => form_content&.[](:bank)&.[](:accountName),
          :iban           => form_content&.[](:bank)&.[](:iban),
          :bank_name      => form_content&.[](:bank)&.[](:bankName),
          :sepa_authorize => form_content&.[](:bank)&.[](:sepaAuthorize),
          :without_sepa   => form_content&.[](:bank)&.[](:withoutSepa),
        },
        :agreement     => {
          :comments               => form_content&.[](:agreement)&.[](:comments),
          :buzzn_supply_agreement => form_content&.[](:agreement)&.[](:buzznSupplyAgreement),
          :general_agreement      => form_content&.[](:agreement)&.[](:generalAgreement),
          :newsletter_agreement   => form_content&.[](:agreement)&.[](:newsletter),
        },
      }.tap do |struct|
        struct[:valid_price] = false
        params = {
          type: 'single',
        }.tap do |p|
          p[:zip] = struct[:calculator][:zip]
          p[:annual_kwh] = begin
                             Integer(struct[:calculator][:annual_kwh])
                           rescue ArgumentError
                             0
                           end
        end
        if params[:zip].nil?
          struct[:price] = {}
        else
          prices = Types::ZipPrices.new(params)
          if prices.max_price
            struct[:price] = prices.max_price.to_hash
            struct[:valid_price] = true
          else
            struct[:price] = {}
          end
        end
      end
    end

    def build_zip
      if form_content&.[](:calculator)&.[](:customerType) == 'organization'
        if form_content&.[](:address)&.[](:organization)&.[](:shippingAddress)&.[](:sameAddress)
          form_content&.[](:personalInfo)&.[](:organization)&.[](:contractingParty)&.[](:zip)
        else
          form_content&.[](:address)&.[](:organization)&.[](:shippingAddress)&.[](:zip)
        end
      elsif form_content&.[](:calculator)&.[](:customerType) == 'person'
        form_content&.[](:address)&.[](:person)&.[](:shippingAddress)&.[](:zip)
      end
    end

    def build_address
      if form_content&.[](:calculator)&.[](:customerType) == 'organization'
        {
          :organization => {
            :shipping_address => {
              :same_address       => form_content&.[](:address)&.[](:organization)&.[](:shippingAddress)&.[](:sameAddress),
              :street             => form_content&.[](:address)&.[](:organization)&.[](:shippingAddress)&.[](:street),
              :house_num          => form_content&.[](:address)&.[](:organization)&.[](:shippingAddress)&.[](:houseNum),
              :zip                => form_content&.[](:address)&.[](:organization)&.[](:shippingAddress)&.[](:zip),
              :city               => form_content&.[](:address)&.[](:organization)&.[](:shippingAddress)&.[](:city),
              :additional_address => form_content&.[](:address)&.[](:organization)&.[](:shippingAddress)&.[](:additionalAddress),
            },
            :billing_address => {
              :another_address    => form_content&.[](:address)&.[](:organization)&.[](:billingAddress)&.[](:anotherAddress),
              :name               => form_content&.[](:address)&.[](:organization)&.[](:billingAddress)&.[](:firstNameLastNameName),
              :street             => form_content&.[](:address)&.[](:organization)&.[](:billingAddress)&.[](:street),
              :house_num          => form_content&.[](:address)&.[](:organization)&.[](:billingAddress)&.[](:houseNum),
              :zip                => form_content&.[](:address)&.[](:organization)&.[](:billingAddress)&.[](:zip),
              :city               => form_content&.[](:address)&.[](:organization)&.[](:billingAddress)&.[](:city),
              :additional_address => form_content&.[](:address)&.[](:organization)&.[](:billingAddress)&.[](:additionalAddress),
            }
          }
        }
      elsif form_content&.[](:calculator)&.[](:customerType) == 'person'
        {
          :person => {
            :shipping_address => {
              :zip                => form_content&.[](:address)&.[](:person)&.[](:shippingAddress)&.[](:zip),
              :city               => form_content&.[](:address)&.[](:person)&.[](:shippingAddress)&.[](:city),
              :street             => form_content&.[](:address)&.[](:person)&.[](:shippingAddress)&.[](:street),
              :house_num          => form_content&.[](:address)&.[](:person)&.[](:shippingAddress)&.[](:houseNum),
              :additional_address => form_content&.[](:address)&.[](:person)&.[](:shippingAddress)&.[](:additionalAddress),
            },
            :billing_address => {
              :another_address    => form_content&.[](:address)&.[](:person)&.[](:billingAddress)&.[](:anotherAddress),
              :name               => form_content&.[](:address)&.[](:person)&.[](:billingAddress)&.[](:firstNameLastNameName),
              :street             => form_content&.[](:address)&.[](:person)&.[](:billingAddress)&.[](:street),
              :house_num          => form_content&.[](:address)&.[](:person)&.[](:billingAddress)&.[](:houseNum),
              :zip                => form_content&.[](:address)&.[](:person)&.[](:billingAddress)&.[](:zip),
              :city               => form_content&.[](:address)&.[](:person)&.[](:billingAddress)&.[](:city),
              :additional_address => form_content&.[](:address)&.[](:person)&.[](:billingAddress)&.[](:additionalAddress),
            }
          }
        }
      else
        {}
      end
    end

    def build_customer
      if form_content&.[](:calculator)&.[](:customerType) == 'organization'
        {
          :name      => form_content&.[](:personalInfo)&.[](:organization)&.[](:contactPerson)&.[](:firstName),
          :last_name => form_content&.[](:personalInfo)&.[](:organization)&.[](:contactPerson)&.[](:lastName),
        }
      elsif form_content&.[](:calculator)&.[](:customerType) == 'person'
        {
          :name      => form_content&.[](:personalInfo)&.[](:person)&.[](:firstName),
          :last_name => form_content&.[](:personalInfo)&.[](:person)&.[](:lastName),
        }
      else
        { :name => 'none' }
      end
    end

    def build_personal_info
      if form_content&.[](:calculator)&.[](:customerType) == 'organization'
        {
          :organization => {
            :contracting_party => {
              :name =>      form_content&.[](:personalInfo)&.[](:organization)&.[](:contractingParty)&.[](:name),
              :street =>    form_content&.[](:personalInfo)&.[](:organization)&.[](:contractingParty)&.[](:street),
              :house_num => form_content&.[](:personalInfo)&.[](:organization)&.[](:contractingParty)&.[](:houseNum),
              :zip =>       form_content&.[](:personalInfo)&.[](:organization)&.[](:contractingParty)&.[](:zip),
              :city =>      form_content&.[](:personalInfo)&.[](:organization)&.[](:contractingParty)&.[](:city),
            },
            :represented_by => {
              :first_and_last_name => form_content&.[](:personalInfo)&.[](:organization)&.[](:representedBy)&.[](:firstAndLastName),
              :email =>               form_content&.[](:personalInfo)&.[](:organization)&.[](:representedBy)&.[](:email),
              :phone =>               form_content&.[](:personalInfo)&.[](:organization)&.[](:representedBy)&.[](:phone),
            },
            :contact_person => {
              :prefix =>     capitalize(form_content&.[](:personalInfo)&.[](:organization)&.[](:contactPerson)&.[](:prefix)),
              :first_name => form_content&.[](:personalInfo)&.[](:organization)&.[](:contactPerson)&.[](:firstName),
              :last_name =>  form_content&.[](:personalInfo)&.[](:organization)&.[](:contactPerson)&.[](:lastName),
              :email =>      form_content&.[](:personalInfo)&.[](:organization)&.[](:contactPerson)&.[](:email),
              :phone =>      form_content&.[](:personalInfo)&.[](:organization)&.[](:contactPerson)&.[](:phone),
              :title =>      form_content&.[](:personalInfo)&.[](:organization)&.[](:contactPerson)&.[](:title),
            },
            :authorized_contact => form_content&.[](:personalInfo)&.[](:authorizedContact) || false
          }
        }
      elsif form_content&.[](:calculator)&.[](:customerType) == 'person'
        {
          :person => {
            :prefix =>     capitalize(form_content&.[](:personalInfo)&.[](:person)&.[](:prefix)),
            :first_name => form_content&.[](:personalInfo)&.[](:person)&.[](:firstName),
            :last_name =>  form_content&.[](:personalInfo)&.[](:person)&.[](:lastName),
            :email =>      form_content&.[](:personalInfo)&.[](:person)&.[](:email),
            :phone =>      form_content&.[](:personalInfo)&.[](:person)&.[](:phone),
            :title =>      form_content&.[](:personalInfo)&.[](:person)&.[](:title),
          }
        }
      else
        {}
      end
    end

  end
end
