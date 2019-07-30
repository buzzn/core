require_relative '../types'

class Types::ZipPriceConfig < Dry::Struct

  constructor_type :strict

  # Kraft Waerme Kopplungs-Gesetz Aufschlag
  attribute :kwkg_aufschlag, Types::Strict::Float
  # Verordnung ueber Vereinbarungen zu abschaltbaren Lasten
  attribute :ab_la_v, Types::Strict::Float
  # Strom NetzEntnahmeVerordnung
  attribute :strom_nev, Types::Strict::Float
  attribute :stromsteuer, Types::Strict::Float
  attribute :eeg_umlage, Types::Strict::Float
  attribute :offshore_haftung, Types::Strict::Float
  attribute :deckungs_beitrag, Types::Strict::Float
  attribute :energie_preis, Types::Strict::Float
  # value added tax
  attribute :vat, Types::Strict::Float
  attribute :yearly_euro_intern, Types::Strict::Float

end
