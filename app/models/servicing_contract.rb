class ServicingContract < ActiveRecord::Base
  belongs_to :organization
  belongs_to :group
  belongs_to :contracting_party

end