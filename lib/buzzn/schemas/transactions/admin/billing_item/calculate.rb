require_relative '../billing_item'
require './app/models/billing_item.rb'

Schemas::Transactions::Admin::BillingItem::Calculate = Schemas::Support.Form(Schemas::Transactions::Update) do
  optional(:begin_date).maybe(:date?)
  optional(:end_date).maybe(:date?)
end