require_relative '../report'

 Schemas::Transactions::Admin::Report::CreateAnnualReport = Schemas::Support.Form do
   required(:begin_date).filled(:date?)
   required(:last_date).filled(:date?)
 end
