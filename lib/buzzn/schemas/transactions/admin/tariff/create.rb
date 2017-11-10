require_relative '../../../constraints/contract/tariff_common'
require_relative '../tariff'

Schemas::Transactions::Admin::Tariff::Create = Schemas::Constraints::Contract::TariffCommon
