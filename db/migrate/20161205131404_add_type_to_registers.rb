class AddTypeToRegisters < ActiveRecord::Migration
  def change
    add_column :registers, :type, :string
    reversible do |dir|
      dir.up do
        Register::Base.all.each do |r|
          type =
            if r.virtual == false
              if r.mode == 'in'
                'Register::Input'
              else
                'Register::Output'
              end
            else
              'Register::Virtual'
            end
          p execute "UPDATE registers SET type='#{type}' where id='#{r.id}';"
        end
      end
      dir.down do
        raise 'can not down grade'
      end
    end
    change_column_null :registers, :type, false
  end
end
