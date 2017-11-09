require_relative '../admin_roda'
require_relative '../../transactions/admin/register/update_formula_part'

module Admin
  class FormulaPartRoda < BaseRoda
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
          Transactions::Admin::Register::UpdateFormulaPart
            .for(shared[LocalpoolRoda::PARENT].registers, part)
            .call(r.params)
        end
      end
    end
  end
end
