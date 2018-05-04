require_relative '../types'

class Types::ZipPriceConfig < Dry::Struct

  # Kraft Waerme Kopplungs-Gesetz Aufschlag
  attribute :kwkg_aufschlag, Types::Coercible::Float
  # Verordnung ueber Vereinbarungen zu abschaltbaren Lasten
  attribute :ab_la_v, Types::Coercible::Float
  # Strom NetzEntnahmeVerordnung
  attribute :strom_nev, Types::Coercible::Float
  attribute :stromsteuer, Types::Coercible::Float
  attribute :eeg_umlage, Types::Coercible::Float
  attribute :offshore_haftung, Types::Coercible::Float
  attribute :deckungs_beitrag, Types::Coercible::Float
  attribute :energie_preis, Types::Coercible::Float
  # value added tax
  attribute :vat, Types::Coercible::Float
  attribute :yearly_euro_intern, Types::Coercible::Float

end
