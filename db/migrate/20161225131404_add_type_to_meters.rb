class AddTypeToMeters < ActiveRecord::Migration
  def change
    add_column :meters, :type, :string
    reversible do |dir|
      dir.up do
        Meter::Base.all.each do |m|
          r = Register::Base.where(meter_id: m).first
          type =
            if r.virtual == false
              'Meter::Real'
            else
              'Meter::Virtual'
            end
          p execute "UPDATE meters SET type='#{type}' where id='#{m.id}';"
        end
        puts 'validate meters'
        Meter::Base.all.each do |m|
          puts "#{m.id}: #{m.valid?}"
        end
        puts 'validates registers'
        Register::Real.all.each do |r|
          puts "#{r.id}: #{r.valid?}"
          if ! r.valid? && r.meter.nil?
            puts "delete #{r.id}"
            r.delete
          end
        end
        Register::Virtual.all.each do |r|
          if r.meter.nil?
            Meter::Virtual.create!(register: r)
            puts "created meter for #{r.id}"
          end
        end
      end
      dir.down do
        raise 'can not down grade'
      end
    end
    change_column_null :meters, :type, false
  end
end
