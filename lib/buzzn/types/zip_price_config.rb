require 'dry-struct'
require 'dry-types'

module Buzzn
  module Types
    class ZipPriceConfig < Dry::Struct
      
      constructor_type :strict

      attribute :kwkg_aufschlag, Buzzn::Types::Strict::Float
      attribute :ab_la_v, Buzzn::Types::Strict::Float
      attribute :strom_nev, Buzzn::Types::Strict::Float
      attribute :stromsteuer, Buzzn::Types::Strict::Float
      attribute :eeg_umlage, Buzzn::Types::Strict::Float
      attribute :offshore_haftung, Buzzn::Types::Strict::Float
      attribute :deckungs_beitrag, Buzzn::Types::Strict::Float
      attribute :energie_preis, Buzzn::Types::Strict::Float
      attribute :vat, Buzzn::Types::Strict::Float
      attribute :yearly_euro_intern, Buzzn::Types::Strict::Float
    end
  end
end
