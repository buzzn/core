begin
  require_relative 'common'
rescue
  require_relative '../support/database_emptier'

  DatabaseEmptier.call

  require_relative 'common'
end

$admin = Fabricate(:admin)
$user  = Fabricate(:user)
$other = Fabricate(:user)
