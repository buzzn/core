require_relative '../admin_roda'

module Admin
  class AnnualReportRoda < BaseRoda

    include Import.args[:env,
                        create_annual_report:
                          'transactions.admin.report.create_annual_report'
                       ]

    plugin :shared_vars

    route do |r|
      localpool = shared[:localpool]
      r.post do
        report = create_annual_report.(resource: localpool, params: r.params)
        filename = Buzzn::Utils::File.sanitize_filename('annualreport.xlsx')
        r.response.headers['Content-Type'] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
        r.response.headers['Content-Disposition'] = "inline; filename=\"#{filename}\""
        r.response.write(report.value!.string)
      end
    end

  end
end
