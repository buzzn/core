require_relative 'common'

$admin = create(:account, :self, :buzzn_operator, password: 'Example123')
$user  = create(:account, :self, password: 'Example123')
$other = create(:account, :self, password: 'Example123')
