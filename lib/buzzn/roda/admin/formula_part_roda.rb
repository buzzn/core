require_relative '../admin_roda'
module Admin
  class FormulaPartRoda < BaseRoda
    CHILDREN = :parts

    plugin :shared_vars

    include Import.args[:env,
                        'transaction.update_formula_part']

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
          update_formula_part.call(r.params,
                                   registers: [shared[LocalpoolRoda::PARENT].registers],
                                   resource: [part])
        end
      end
    end
  end
end
