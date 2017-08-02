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
          extras = {}
          extras['operand'] = shared[LocalpoolRoda::PARENT].registers.retrieve(r.params.delete('operand_id')).object if r.params['operand_id'] 

          update_formula_part.call(r.params, resource: [part, extras])
        end
      end
    end
  end
end
