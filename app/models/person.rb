# coding: utf-8
class Person < ContractingParty
  include Filterable

  # prefixes
  FEMALE = 'F'
  MALE = 'M'
  enum prefix: {
         female: FEMALE,
         male:   MALE
       }
  PREFIXES = [FEMALE, MALE]

  # preferred languages
  GERMAN = 'de'
  ENGLISH = 'en'
  enum preferred_language: {
         german:  GERMAN,
         english: ENGLISH
       }
  PREFERRED_LANGUAGES = [GERMAN, ENGLISH]

  validate :validate_invariants

  def validate_invariants
  end

  scope :restricted, ->(uuids) do
    where(id: uuids)
  end

  def self.search_attributes
    [:first_name, :last_name, :email]
  end

  def self.filter(value)
    do_filter(value, *search_attributes)
  end

  def name
    "#{first_name} #{last_name}"
  end
end
