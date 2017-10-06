# Generates and caches DB records that we need to access globally.
module SeedSingletons
  class << self
    def persons
      @persons ||= OpenStruct.new(
        wolfgang: FactoryGirl.create(:person, :with_bank_account, :wolfgang)
      )
    end
  end
end