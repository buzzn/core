require_relative '../report'

 Schemas::Transactions::Admin::Report::CreateAnnualReport = Schemas::Support.Form do
   required(:begin).filled(:date?)
   required(:end).filled(:date?)
 end
