class RegisterResource < ApplicationResource

  attributes  :obis,
              :label,
              :low_load_ability,
              :digits_before_comma,
              :decimal_digits,
              :virtual

end