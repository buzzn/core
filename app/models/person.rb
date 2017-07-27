# coding: utf-8
class Person < ContractingParty
  self.table_name = :persons

  include Filterable

  has_one :address, as: :addressable, dependent: :destroy

  # TODO remove this when decided on how to make the attachments (Document)
  mount_uploader :image, PictureUploader

  # prefixes
  FEMALE = 'F'
  MALE = 'M'
  enum prefix: {
         female: FEMALE,
         male:   MALE
       }
  PREFIXES = [FEMALE, MALE]

  # titles
  DR = 'Dr.'
  PROF = 'Prof.'
  PROF_DR = 'Prof. Dr.'
  enum titles: {
         prof: PROF,
         dr: DR,
         prof_dr: PROF_DR
       }
  TITLES = [DR, PROF, PROF_DR]

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
