class ContractDocument < ActiveRecord::Base
  belongs_to :document
  belongs_to :contract
end
