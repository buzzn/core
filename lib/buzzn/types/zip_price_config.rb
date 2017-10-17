require 'dry-struct'
require 'dry-types'

module Buzzn
  module Types
    class ZipPriceConfig < Dry::Struct
      
      constructor_type :strict

      # Kraft Wärme Kopplungs-Gesetz Aufschlag
      attribute :kwkg_aufschlag, Buzzn::Types::Strict::Float
      # Verordnung über Vereinbarungen zu abschaltbaren Lasten
      attribute :ab_la_v, Buzzn::Types::Strict::Float
      # Strom NetzEntnahmeVerordnung 
      attribute :strom_nev, Buzzn::Types::Strict::Float
      attribute :stromsteuer, Buzzn::Types::Strict::Float
      attribute :eeg_umlage, Buzzn::Types::Strict::Float
      attribute :offshore_haftung, Buzzn::Types::Strict::Float
      attribute :deckungs_beitrag, Buzzn::Types::Strict::Float
      attribute :energie_preis, Buzzn::Types::Strict::Float
      # value added tax
      attribute :vat, Buzzn::Types::Strict::Float
      attribute :yearly_euro_intern, Buzzn::Types::Strict::Float
    end
  end
end
