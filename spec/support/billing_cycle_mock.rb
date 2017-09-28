class BillingCycle

  def self.billings(b = nil)
    @b = b if b
    @b
  end

  alias :create_regular_billings_old :create_regular_billings

  def create_regular_billings(*args)
    self.class.billings || create_regular_billings_old(*args)
  end
end
