require_relative '../admin_roda'
require 'buzzn/utils/file'

module Admin
  class GlobalReportRoda < BaseRoda

    include Import.args[:env,
                        'transactions.admin.global_report.generate_meter_report',
                        'transactions.admin.global_report.return_report',
                      ]

    #plugin :shared_vars

    route do |r|

        r.on 'meter_report_id' do
          r.get! do
            generate_meter_report.()
          end
        end

        r.on 'report' do
          r.post! do
            report = return_report.(params: r.params)
            filename = Buzzn::Utils::File.sanitize_filename('report.csv')
            r.response.headers['Content-Type'] = 'text/csv;charset=ISO-8859'
            r.response.headers['Content-Disposition'] = "inline; filename=\"#{filename}\""
            r.response.write(report.value!)
          end
        end

    end
  end
end
