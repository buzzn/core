require_relative '../admin_roda'

class Admin::ReportRoda < BaseRoda

  include Import.args[:env,
                      create_eeg_report: 'transactions.admin.report.create_eeg_report'
                     ]

  plugin :shared_vars

  route do |r|

    localpool = shared[:localpool]

    r.on 'eeg' do
      r.post! do
        create_eeg_report.(resource: localpool, params: r.params)
      end
    end

  end

end
