module Buzzn::Pdfs
  class LSN_A01 < Buzzn::PdfGenerator

    TEMPLATE = 'lsn_a01.slim'

    class ContractDecorator < SimpleDelegator

      def localpool
        register.group
      end

      def contractor_contact
        case contractor
        when User
          contractor
        when Organization
          contractor.managers.first
        end
      end

      def date
        @date ||= Date.today
      end

      def move_in
        super ? 'ja' : 'nein'
      end

      def payment_now
        payments.current(date).first.price_cents.to_f / 100
      end

      def tariff_now
        tariffs.current(date).first
      end

      def base_price_euro
        tariff_now.baseprice_cents_per_month.to_f / 100
      end
    end

    def initialize(localpool_power_taker_contract)
      super({})
      @contract = ContractDecorator.new(localpool_power_taker_contract)
    end

    def power_taker
      @contract
    end

    def place
      @contract.contractor.address.city
    end

    def date
      @contract.date.strftime('%-d.%-m.%Y')
    end

    def addressing
      case user = @contract.contractor
      when User
        prefix = case user.profile.gender
                 when 'female'
                   "Sehr geehrte Frau"
                 when 'male'
                   "Sehr geehrter Herr"
                 else
                   "Hallo"
                 end
        "#{prefix} #{user.profile.title} #{power_taker.contractor.name}"
      when Organization
        "Sehr geehrte Damen und Herren"
      else
        raise ArgumentError.new("unknown type of contractor: #{contract}")
      end
    end
  end
end
