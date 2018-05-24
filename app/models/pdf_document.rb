class PdfDocument < ActiveRecord::Base

  belongs_to :localpool, class_name: 'Group::Localpool', foreign_key: :localpool_id
  belongs_to :contract, class_name: 'Contract::Base', foreign_key: :contract_id
  belongs_to :billing
  belongs_to :document
  belongs_to :template

end
