require_relative '../admin_roda'

module Admin
  class FormulaPartRoda < BaseRoda

    include Import.args[:env,
                        'transactions.admin.register.update_formula_part'
                       ]

    CHILDREN = :parts

    plugin :shared_vars

    route do |r|

      parts = shared[CHILDREN]

      r.get! do
        parts
      end

      r.on :id do |id|
        part = parts.retrieve(id)

        r.get! do
          part
        end

        r.patch! do
          update_formula_part.(
            resource: part,
            params: r.params,
            registers: shared[LocalpoolRoda::PARENT].registers
          )
        end
      end
    end

  end
end
