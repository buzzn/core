module PersonOrganizationRelation

  def self.generate(model, name)
    model.belongs_to :"#{name}_person", class_name: 'Person', foreign_key: :"#{name}_person_id"
    model.belongs_to :"#{name}_organization", class_name: 'Organization', foreign_key: :"#{name}_organization_id"
    model.class_eval do

      define_method(name) do
        send(:"#{name}_organization") || send(:"#{name}_person")
      end

      define_method(:"#{name}=") do |new_value|
        case new_value
        when Person
          self.send(:"#{name}_person=", new_value)
          self.send(:"#{name}_organization=", nil)
        when Organization
          self.send(:"#{name}_organization=", new_value)
          self.send(:"#{name}_person=", nil)
        when NilClass
          # allow nil
          self.send(:"#{name}_organization=", nil)
          self.send(:"#{name}_person=", nil)
        else
          raise "Can't assign #{new_value.inspect} as #{name}, not a Person or Organization."
        end
      end
    end
  end

end
