require_relative '../localpool_metering_point_operator'
require_relative '../base'

Schemas::Transactions::Admin::Contract::Localpool::MeteringPointOperator::Create = Schemas::Support.Form(Schemas::Transactions::Admin::Contract::Base) do
  required(:begin_date).filled(:date?)
end
