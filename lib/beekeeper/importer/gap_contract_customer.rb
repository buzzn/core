class Beekeeper::Importer::GapContractCustomer

  LOOKUP = {
    # localpool slug => contract number which has the customer to be used
    'cherubinistr'                      => '60009/8',
    'gertrud-grunow-strasse'            => '60030/37',
    'gotthardstrasse'                   => '60010/1',
    'hofackerstrasse'                   => '60006/3',
    'mehrgenerationenplatz-forstenried' => '60015/73',
    'wachsbleiche'                      => '60014/12',
    'wagnis'                            => '60008/52',
    'scheffelstrasse'                   => '60044/7'
  }

  class << self

    def find_by_localpool(localpool)
      buzznid = LOOKUP[localpool.slug]
      contract_customer_for_buzznid(buzznid) if buzznid
    end

    def contract_customer_for_buzznid(buzznid)
      contract_number, contract_number_addition = buzznid.split('/')
      contract = Contract::LocalpoolPowerTaker.find_by(contract_number: contract_number, contract_number_addition: contract_number_addition)
      contract.customer
    end

  end

end
