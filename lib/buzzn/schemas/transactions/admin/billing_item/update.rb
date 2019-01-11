require_relative '../billing_item'
require './app/models/billing_item.rb'

Schemas::Transactions::Admin::BillingItem::Update = Schemas::Support.Form(Schemas::Transactions::Update) do
  optional(:begin_reading_id).maybe(:int?)
  optional(:end_reading_id).maybe(:int?)
end
