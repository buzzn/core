require_relative 'generator'

module Mail
  class PowerTaker < Generator

    attr_reader :form_content

    def initialize(form_content)
      super
      @form_content = form_content
    end

    protected

    def build_struct
      {
        # plain
        moving_in: form_content[:moving_in],
        moving_in_date: form_content[:moving_in_date],
        counter_id: form_content[:counter_id],
        count_id: form_content[:count_id],
        previous_a_conto: form_content[:previous_a_conto],
        estimated_kwh: form_content[:estimated_kwh],
        message: form_content[:message],
        reference: form_content[:reference],
        # builders
        customer: build_customer(form_content[:customer]),
        previous_supplier: build_previous_supplier(form_content[:previous_supplier]),
        partner: build_partner(form_content[:partner])
      }
    end

    def build_customer(customer)
      {
        name: customer[:name],
        last_name: customer[:last_name],
        gender: customer[:gender],
        phone: customer[:phone],
        email: customer[:email]
      }
    end

    def build_partner(partner)
      {
        name: partner[:name],
        represented_by: partner[:represented_by],
        address: {
          street: partner[:address][:street],
          addition: partner[:address][:addition],
          zip: partner[:address][:zip],
          city: partner[:address][:city]
        }
      }
    end

    def build_previous_supplier(supplier)
      {
        name: supplier[:last_name],
        customer_no: supplier[:customer_no],
        contract_no: supplier[:contract_no]
      }
    end

  end
end
