require_relative '../admin_roda'

module Admin
  # Exports group members.
  class GroupMemberExportRoda < BaseRoda

    include Import.args[:env,
                        group_member_dtvf_export:
                          'transactions.admin.exchange.group_member_dtvf_export'
                       ]

    plugin :shared_vars

    route do |r|
      localpool = shared[:localpool]
      r.get do
        export = group_member_dtvf_export.(resource: localpool,
                                           params: r.params)
        filename = Buzzn::Utils::File.sanitize_filename(
          'group_members_DTVF.csv'
        )
        r.response.headers['Content-Type'] = 'text/csv'
        r.response.headers['Content-Disposition'] =
          "inline; filename=\"#{filename}\""
        r.response.write(export.value!)
      end
    end

  end
end
