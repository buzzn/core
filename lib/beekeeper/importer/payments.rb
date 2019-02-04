class Beekeeper::Importer::Payments

  attr_reader :logger

  def initialize(logger)
    @logger = logger
  end

  def run(contract, payments)
    payments.each do |payment|
      contract.payments.create(payment)
    end
  end

end
