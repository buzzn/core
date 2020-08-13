namespace :config do

  desc 'Set various configs'
  task :set => :environment do
    require './lib/buzzn/types/billing_config'
    CoreConfig.store Types::BillingConfig.new(vat: 1.19, vat2: 1.16)
  end
end
