class EnumsForFormulaParts < ActiveRecord::Migration
  def up
    create_enum :operator, *Register::FormulaPart.operators.values

    rename_column :formula_parts, :operator, :opt
    add_column :formula_parts, :operator, :operator, null: true, index: true

    Register::FormulaPart.all.each do |a|
      a.update(operator: a.opt)
    end

    change_column_null :formula_parts, :operator, false
    remove_column :formula_parts, :opt

    Register::FormulaPart.reset_column_information
  end
end
