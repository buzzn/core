module Buzzn::Validation
  Form = Dry::Validation.Form(build: false) do
    configure do

      config.messages_file = 'config/locales/errors.yml'

      #def self.messages
      #  Dry::Validation::Messages.default.merge(
      #    en: { errors: { iban?: 'must be a valid iban' } }
      #  )
      #end

      predicates(Predicates)
    end
  end
end
