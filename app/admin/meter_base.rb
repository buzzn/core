ActiveAdmin.register Meter::Base do

  menu :parent => "System", :label => "Meter"

  index do
    id_column
    column :mode
    column :type
    column :manufacturer_product_name
    column :manufacturer_product_serialnumber
    column :data_provider_name

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
