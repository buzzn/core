class Beekeeper::Importer::GapContractCustomer

  LOOKUP = {
    # localpool slug => contract number which has the customer to be used
    'am-kindergarten'                   => '60026/1',
    'am-urtlgraben'                     => '60021/5',
    'bahnhofstr'                        => '60043/1',
    'cherubinistr'                      => '60009/8',
    'fritz-winter-strasse'              => '60029/79',
    'gertrud-grunow-strasse'            => '60030/37',
    'gotthardstrasse'                   => '60010/1',
    'haeberlstrasse'                    => '60005/22',
    'heigelstrasse'                     => '60050/5',
    'hoernleweg'                        => '60064/1',
    'hofackerstrasse'                   => '60006/3',
    'huehnefeldstrasse'                 => '60052/1',
    # Using contract 4 instead of 1, they have the same customer.
    # Contract 1 isn't imported yet since it uses a virtual register.
    'karmensoeldnerstrasse'             => '60019/4',
    'landsbergerstrasse'                => '60048/1',
    'ligsalzstr'                        => '60057/4',
    'lindenstrasse'                     => '60024/2',
    'lissi-kaeser-strasse'              => '60041/1',
    'loft'                              => '60049/27',
    'marktplatz'                        => '60054/6',
    'martinusstrasse'                   => '60053/6',
    'mehrgenerationenplatz-forstenried' => '60015/73',
    'michaelisstrasse'                  => '60025/3',
    'orleansstrasse'                    => '60007/25',
    'panoramastrasse'                   => '60004/1',
    'prof-kurt-huber-str'               => '60040/6',
    'reinmarplatz'                      => '60017/52',
    'ruhensdorf'                        => '60020/1',
    'scheffelstrasse'                   => '60044/7',
    'schweigerweg'                      => '60002/14',
    'sulz'                              => '60051/1',
    'tassiloweg'                        => '60027/1',
    'ude'                               => '60028/11',
    'wachsbleiche'                      => '60014/12',
    'wagnis'                            => '60008/52',
    'wagnisart-afrika'                  => '60034/8',
    'wagnisart-australien-asien'        => '60035/52',
    'wagnisart-europa-amerika'          => '60036/29',
    'woge'                              => '60023/23',
  }

  class << self

    def find_by_localpool(localpool)
      buzznid = LOOKUP[localpool.slug]
      contract_customer_for_buzznid(buzznid) if buzznid
    end

    def contract_customer_for_buzznid(buzznid)
      contract_number, contract_number_addition = buzznid.split('/')
      contract = Contract::LocalpoolPowerTaker.find_by(contract_number: contract_number, contract_number_addition: contract_number_addition)
      contract&.customer
    end

  end

end