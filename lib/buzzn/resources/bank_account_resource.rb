class BankAccountResource < Buzzn::Resource::Entity

  model BankAccount

  attributes  :holder,
              :bank_name,
              :bic,
              :iban,
              :direct_debit,
              :updatable, :deletable

  # @note This methods only works on german bank accounts.
  # @return [String] The national bank code. NOT bic!
  def bank_code()
    iban[4..11]
  end

  # @note This methods only works on german bank accounts.
  # @return [String] The bank account number. NOT bic!
  def bank_account_number
    iban[12..21]
  end

  # @note This methods only works on german bank accounts.
  # @return [String] Letters used to identify the bank's country.
  def country_code
    iban[0..1]
  end
end
