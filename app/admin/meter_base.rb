ActiveAdmin.register Meter::Base do

  menu :parent => "System", :label => "Meter"

  index do
    id_column
    column :mode
    column :type
    column :product_name
    column :product_serialnumber

    column "registers" do |meter|
      if meter.type == "Meter::Real"
        s = []
        meter.registers.each do |register|
          s << register.name
        end
        s.join(', ')
      end
    end

    actions
  end


end
