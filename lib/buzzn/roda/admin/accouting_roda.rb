class Admin::AccountingRoda < BaseRoda

  include Import.args[:env,
                      'transactions.admin.accounting.book',
                     ]

  plugin :shared_vars

  route do |r|

    contract = shared[:contract]

    r.get!('balance_sheet') do
      contract.balance_sheet
    end

    r.post!('book') do
      book.(resource: contract.accounting_entries, params: r.params)
    end

    r.others!

  end

end
